<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\Setting;
use App\Models\Category;
use App\Models\Video;
use App\Models\Notifications;
use App\Models\User;

class NotificationController extends Controller
{
    public function __construct() {
        $this->destinationPath = public_path() .'/' . config('global.NOTIFICATION_IMG_PATH');
    }

    public function index(Request $request) {
        $category = Category::all();
        $video = Video::all();
        return view('notification', compact('category','video'));
    }

    public function show() {
        $offset = 0;
        $limit = 10;
        $sort = 'id';
        $order = 'DESC';

        if (isset($_GET['offset']))
            $offset = $_GET['offset'];
        if (isset($_GET['limit']))
            $limit = $_GET['limit'];

        if (isset($_GET['sort']))
            $sort = $_GET['sort'];
        if (isset($_GET['order']))
            $order = $_GET['order'];

        $sql = DB::table('tbl_notification');
        if (isset($_GET['search']) && !empty($_GET['search'])) {
            $search = $_GET['search'];
            $sql->where('id', 'LIKE', "%$search%")->orwhere('title', 'LIKE', "%$search%")->orwhere('type', 'LIKE', "%$search%")->orwhere('users', 'LIKE', "%$search%");
        }
        $total = $sql->count();

        $sql->orderBy($sort, $order)->skip($offset)->take($limit);
        $res = $sql->get();

        $bulkData = array();
        $bulkData['total'] = $total;
        $rows = array();
        $tempRow = array();
        $count = 1;
        foreach ($res as $row) {
            $image = (!empty($row->image)) ? 'public/' . config('global.NOTIFICATION_IMG_PATH') . $row->image : '';
            $operate = '<a class="'.config('global.DELETE_ICON').'" data-id=' . $row->id . ' data-image=' . $row->image . '><i class="fa fa-trash"></i></a>';

            $type = $row->type;
            if($type == 'video'){
                $type_name = DB::table('tbl_video')->where('id', $row->type_id)->value('title');
            } else {
                $type_name = DB::table('tbl_category')->where('id', $row->type_id)->value('category_name');
            }
            
            $tempRow['type_name'] = $type_name;
            $tempRow['count'] = $count;
            $tempRow['id'] = $row->id;
            $tempRow['type'] = $row->type;
            $tempRow['type_id'] = $row->type_id;
            $tempRow['title'] = $row->title;
            $tempRow['message'] = $row->message;
            $tempRow['users'] = $row->users;
            $tempRow['date'] = $row->date;
            $tempRow['image_url'] = (!empty($row->image)) ? '<a href=' . $image . ' data-lightbox="Images"><img src="' . $image . '" height=50, width=50 ></a>' : 'No Image';
            $tempRow['operate'] = $operate;
            $rows[] = $tempRow;
            $count++;
        }

        $bulkData['rows'] = $rows;
        return response()->json($bulkData);
    }

    public function store(Request $request) {
        $serverKey = Setting::select('message')->where('type','notification_setting')->pluck('message')->first();
        if($serverKey != '') {
            $request->validate([
                'file' => 'image|mimes:jpeg,png,jpg',
                'type' => 'required',
                'category_id' => 'required_if:type,==,category',
                'video_id' => 'required_if:type,==,video',
                'users' => 'required',
                'user_id' => 'required_if:users,==,selected',
                'title' => 'required',
                'message' => 'required',
            ],[
                'user_id.*' => trans('message.select_user_from_table'),
            ]
        );
            $imageName = '';
            if($request->hasFile('file')) {
                if (!is_dir($this->destinationPath)) {
                    mkdir($this->destinationPath, 0777, TRUE);                
                }
                // image upload
                $image = $request->file('file');
                $imageName = microtime(true) . "." . $image->getClientOriginalExtension();
                $image->move($this->destinationPath, $imageName);  
            } 
            if($request->users == 'all') {
                $user_id = '';
                $fcm_ids = User::whereNotNull('fcm_id')->where('role', 'user')->pluck('fcm_id')->all();
            } else {
                $user_id = $request->user_id;
                $fcm_ids = explode(',', $request->fcm_id);
            }
    
            if($request->type == "default"){
                $type_id = 0;
            } else {
                $type_id = ($request->type == 'category') ? $request->category_id : $request->video_id;
            }
    
            Notifications::create([     
                'title' => $request->title,           
                'message' => $request->message,           
                'image' => $imageName,
                'type' => $request->type,
                'type_id' => $type_id,
                'users' => $request->users,
                'user_id' => $user_id,
                'date' => date('Y-m-d'),
            ]);

            $img = ($imageName!='') ? url('public') . '/' . config('global.NOTIFICATION_IMG_PATH'). $imageName : "";

            $notification_data = [
                'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                "title" => $request->title,
                "body" => $request->message,  
                "image" => $img,  
                'users' => $request->users,
                "user_id" => $user_id,  
                "type" => $request->type,   
                'type_id' => $type_id,
            ];
            
            $registrationIDs = $fcm_ids;

            $success = $failure = 0;
            
            $registrationIDs_chunks = array_chunk($registrationIDs, 1000);

            foreach ($registrationIDs_chunks as $registrationIDs) {
                $fcmFields = array(
                    "registration_ids" => $fcm_ids,
                    'priority' => 'high',
                    "notification" => $notification_data,
                    "data" => $notification_data
                );
        
                $headers = array(
                    'Authorization: key=' . $serverKey,
                    'Content-Type: application/json'
                );
        
                $ch = curl_init();
                curl_setopt($ch, CURLOPT_URL, 'https://fcm.googleapis.com/fcm/send');
                curl_setopt($ch, CURLOPT_POST, true);
                curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
                curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
                curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
                curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($fcmFields));
                $result = curl_exec($ch);
                curl_close($ch);
        
                $result = json_decode($result, 1);
        
                $success += $result['success'];
                $failure += $result['failure'];
            }
            return redirect('notification')->with('success', trans('message.notification_insert'));
        } else {
            return redirect('notification')->with('error', trans('message.set_fcm_server_key'));
        }       
    }

    public function destroy(Request $request) {
        $id = $request->id;
        $image = $request->image;
        
        if (Notifications::where('id', $id)->delete()){
            if($image != ''){
                if (file_exists($this->destinationPath . $image)) {
                    unlink($this->destinationPath . $image);
                }
            }            
            return response()->json([
                'error' => false,
                'message' => trans('message.notification_delete')
            ]);
        } else {
            return response()->json([
                'error' => true,
                'message' => trans('message.something_wrong')   
            ]);
        }
    }
}
