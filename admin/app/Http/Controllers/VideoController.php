<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\Category;
use App\Models\Video;

class VideoController extends Controller
{

    public function __construct()
    {
        $this->destinationPath = public_path() . '/' . config('global.VIDEO_IMG_PATH');
    }

    public function index()
    {
        $category = Category::all();
        return view('video', compact('category'));
    }

    public function show()
    {
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

        $sql = DB::table('tbl_video')->select('tbl_video.*', 'tbl_category.category_name')->join('tbl_category', 'tbl_category.id', '=', 'tbl_video.category_id');
        if (isset($_GET['category_id']) && !empty($_GET['category_id'])) {
            $sql->where('category_id', $_GET['category_id']);
        }
        if (isset($_GET['search']) && !empty($_GET['search'])) {
            $search = $_GET['search'];
            $sql->where('tbl_video.id', 'LIKE', "%$search%")->orwhere('tbl_video.title', 'LIKE', "%$search%")->orwhere('tbl_video.video_id', 'LIKE', "%$search%")->orwhere('tbl_video.duration', 'LIKE', "%$search%");
        }
        $total = $sql->count();

        $sql->orderBy($sort, $order)->skip($offset)->take($limit);
        $res = $sql->get();

        $bulkData = array();
        $bulkData['total'] = $total;
        $rows = array();
        $tempRow = array();
        $count = 1;

        $icon = array(
            '1' => trans('message.youtube'),
            '2' => trans('message.viemo'),
            '3' => trans('message.external_link'),
        );

        foreach ($res as $row) {
            $image = (!empty($row->image)) ? 'public/' . config('global.VIDEO_IMG_PATH') . $row->image : '';
            $operate = '<a class="' . config('global.EDIT_ICON') . '" data-id=' . $row->id . ' data-bs-toggle="modal" data-bs-target="#editDataModal" title="Edit"><i class="fa fa-edit"></i></a>&nbsp;&nbsp;';
            $operate .= '<a class="' . config('global.DELETE_ICON') . '" data-id=' . $row->id . ' data-image=' . $row->image . '><i class="fa fa-trash"></i></a>';

            $tempRow['image'] = ($row->image != null && $row->image != '') ? $row->image : '';
            $tempRow['count'] = $count;
            $tempRow['id'] = $row->id;
            $tempRow['category_id'] = $row->category_id;
            $tempRow['category_name'] = $row->category_name;
            $tempRow['title'] = $row->title;
            $tempRow['video_type'] = $row->video_type;
            // $tempRow['video_type1'] = (isset($row->video_type) && $row->video_type != '') ? $icon[trim($row->video_type)] : $icon['1'];
            $tempRow['video_id'] = $row->video_id;
            $tempRow['duration'] = $row->duration;
            $tempRow['image_url'] = ($image) ? '<a href=' . $image . ' data-lightbox="Images"><img src=' . $image . ' height=50, width=50 ></a>' : '';
            $tempRow['description'] = $row->description;
            $tempRow['date'] = $row->date;
            $tempRow['type1'] = $row->type;
            $tempRow['views'] = $row->views;

            $tempRow['type'] = ($row->type) ? "<span class='badge rounded-pill bg-success'>" . trans('message.paid') . "</span>" : "<span class='badge rounded-pill bg-warning'>" . trans('message.free') . "</span>";
            $tempRow['operate'] = $operate;
            $rows[] = $tempRow;
            $count++;
        }

        $bulkData['rows'] = $rows;
        return response()->json($bulkData);
    }

    public function store(Request $request)
    {
        $request->validate([
            'category_id' => 'required',
            'title' => 'required',
            'video_type' => 'required',
            'video_id' => 'required',
            'file' => 'image|mimes:jpeg,png,jpg|required_if:video_type,==,3',
            'duration' => 'required',
            'type' => 'required',
        ]);
        $imageName = '';
        if ($request->hasFile('file')) {
            if (!is_dir($this->destinationPath)) {
                mkdir($this->destinationPath, 0777, TRUE);
            }
            // image upload
            $image = $request->file('file');
            $imageName = microtime(true) . "." . $image->getClientOriginalExtension();
            $image->move($this->destinationPath, $imageName);
        }

        Video::create([
            'category_id' => $request->category_id,
            'title' => $request->title,
            'video_type' => $request->video_type,
            'video_id' => $request->video_id,
            'duration' => $request->duration,
            'image' => $imageName,
            'description' => ($request->description) ? $request->description : '',
            'type' => $request->type,
            'date' => date('Y-m-d'),
        ]);
        return redirect('video')->with('success', trans('message.video_insert'));
    }

    public function update(Request $request)
    {
        $request->validate([
            'category_id' => 'required',
            'title' => 'required',
            'video_type' => 'required',
            'video_id' => 'required',
            'duration' => 'required',
            'edit_type' => 'required',
        ]);
        $id = $request->edit_id;
        $data['category_id'] = $request->category_id;
        $data['title'] = $request->title;
        $data['video_type'] = $request->video_type;
        $data['video_id'] = $request->video_id;
        $data['duration'] = $request->duration;
        $data['type'] = $request->edit_type;
        $data['description'] = ($request->description) ? $request->description : '';
        if ($request->hasFile('update_file')) {
            $image = $request->file('update_file');
            $imageName = microtime(true) . "." . $image->getClientOriginalExtension();
            $image->move($this->destinationPath, $imageName);

            $image = $request->image;
            if ($image != '') {
                if (file_exists($this->destinationPath . $image)) {
                    unlink($this->destinationPath . $image);
                }
            }
            $data['image'] = $imageName;
        }

        Video::where('id', $id)->update($data);
        return response()->json([
            'error' => false,
            'message' => trans('message.video_update')
        ]);
    }

    public function destroy(Request $request)
    {
        $id = $request->id;
        $image = $request->image;
        if (Video::where('id', $id)->delete()) {
            if (file_exists($this->destinationPath . $image)) {
                unlink($this->destinationPath . $image);
            }
            return response()->json([
                'error' => false,
                'message' => trans('message.video_delete')
            ]);
        } else {
            return response()->json([
                'error' => true,
                'message' => trans('message.something_wrong')
            ]);
        }
    }
}
