<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\Slider;
use App\Models\Category;
use App\Models\Video;

class SliderController extends Controller
{
    public function __construct() {
        $this->destinationPath = public_path() .'/' . config('global.SLIDER_IMG_PATH');
    }

    public function index(Request $request) {
        $category = Category::all();
        $video = Video::all();
        return view('slider', compact('category','video'));
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

        $sql = DB::table('tbl_slider');
        if (isset($_GET['search']) && !empty($_GET['search'])) {
            $search = $_GET['search'];
            $sql->where('id', 'LIKE', "%$search%")->orwhere('type', 'LIKE', "%$search%");
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
            $image = (!empty($row->image)) ? 'public/' . config('global.SLIDER_IMG_PATH') . $row->image : '';
            $operate = '<a class="'.config('global.EDIT_ICON').'" data-id=' . $row->id . ' data-bs-toggle="modal" data-bs-target="#editDataModal" title="Edit"><i class="fa fa-edit"></i></a>&nbsp;&nbsp;';
            $operate .= '<a class="'.config('global.DELETE_ICON').'" data-id=' . $row->id . ' data-image=' . $row->image . '><i class="fa fa-trash"></i></a>';

            $type = $row->type;
            if($type == 'video'){
                $type_name = DB::table('tbl_video')->where('id', $row->type_id)->value('title');
                // $type_des = DB::table('tbl_video')->where('id', $row->type_id)->value('description');
            } else {
                $type_name = DB::table('tbl_category')->where('id', $row->type_id)->value('category_name');
                // $type_des = DB::table('tbl_category')->where('id', $row->type_id)->value('description');
            }
            
            $tempRow['type_name'] = $type_name;
            $tempRow['image'] = $row->image;
            $tempRow['count'] = $count;
            $tempRow['id'] = $row->id;
            $tempRow['type'] = $row->type;
            $tempRow['type_id'] = $row->type_id;
            $tempRow['date'] = $row->date;
            $tempRow['image_url'] = '<a href=' . $image . ' data-lightbox="Images"><img src=' . $image . ' height=50, width=50 ></a>';
            $tempRow['operate'] = $operate;
            $rows[] = $tempRow;
            $count++;
        }

        $bulkData['rows'] = $rows;
        return response()->json($bulkData);
    }

    public function store(Request $request) {
        $request->validate([
            'file' => 'required|image|mimes:jpeg,png,jpg',
            'type' => 'required',
            'category_id' => 'required_if:type,==,category',
            'video_id' => 'required_if:type,==,video',
        ]);
        if (!is_dir($this->destinationPath)) {
            mkdir($this->destinationPath, 0777, TRUE);                
        }
        // image upload
        $image = $request->file('file');
        $imageName = microtime(true) . "." . $image->getClientOriginalExtension();
        $image->move($this->destinationPath, $imageName);   

        Slider::create([                
            'image' => $imageName,
            'type' => $request->type,
            'type_id' => ($request->type == 'category') ? $request->category_id : $request->video_id,
            'date' => date('Y-m-d'),
        ]);
        return redirect('slider')->with('success', trans('message.slider_insert'));
    }

    public function update(Request $request) {
        $request->validate([
            'type' => 'required',
            'edit_category_id' => 'required_if:type,==,category',
            'edit_video_id' => 'required_if:type,==,video',
        ]);

        $id = $request->edit_id;
        if ($request->hasFile('update_file')) {
            $image = $request->file('update_file');
            $imageName = microtime(true) . "." . $image->getClientOriginalExtension();
            $image->move($this->destinationPath, $imageName);  

            $image = $request->image;
            if (file_exists($this->destinationPath . $image)) {
                unlink($this->destinationPath . $image);
            }
            $data['image'] = $imageName;
        }

        $data['type'] = $request->type;
        $data['type_id'] = ($request->type == 'category') ? $request->edit_category_id : $request->edit_video_id;

        Slider::where('id', $id)->update($data);
        return response()->json([
            'error' => false,
            'message' => trans('message.slider_update')
        ]);        
    }

    public function destroy(Request $request) {
        $id = $request->id;
        $image = $request->image;
        
        if (Slider::where('id', $id)->delete()){
            if (file_exists($this->destinationPath . $image)) {
                unlink($this->destinationPath . $image);
            }
            return response()->json([
                'error' => false,
                'message' => trans('message.slider_delete')
            ]);
        } else {
            return response()->json([
                'error' => true,
                'message' => trans('message.something_wrong')
            ]);
        }
    }
}
