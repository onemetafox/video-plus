<?php

namespace App\Http\Controllers;

use App\Models\Category;
use App\Models\Video;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class CategoryController extends Controller {
    
    public function __construct() {
        $this->destinationPath = public_path() .'/' . config('global.CATEGORY_IMG_PATH');
    }
    
    public function index(Request $request) {
        return view('category');
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
        
        $sql = DB::table('tbl_category');
        if (isset($_GET['search']) && !empty($_GET['search'])) {
            $search = $_GET['search'];
            $sql->where('id', 'LIKE', "%$search%")->orwhere('category_name', 'LIKE', "%$search%");
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
            $image = (!empty($row->image)) ? 'public/' . config('global.CATEGORY_IMG_PATH') . $row->image : '';
            $operate = '<a class="'.config('global.EDIT_ICON').'" data-id=' . $row->id . ' data-bs-toggle="modal" data-bs-target="#editDataModal" title="Edit"><i class="fa fa-edit"></i></a>&nbsp;&nbsp;';
            $operate .= '<a class="'.config('global.DELETE_ICON').'" data-id=' . $row->id . ' data-image=' . $row->image . '><i class="fa fa-trash"></i></a>';
            
            $total_video = DB::table('tbl_video')->where('category_id', $row->id)->count();
            $tempRow['total_video'] = $total_video;
            $tempRow['image'] = $row->image;
            $tempRow['count'] = $count;
            $tempRow['id'] = $row->id;
            $tempRow['category_name'] = $row->category_name;
            $tempRow['date'] = $row->date;
            $tempRow['description'] = $row->description;
            $tempRow['image_url'] = '<a href=' . $image . ' data-lightbox="Images"><img src=' . $image . ' height=50, width=50 ></a>';
            $tempRow['sequence'] = $row->sequence;
            $tempRow['operate'] = $operate;
            $rows[] = $tempRow;
            $count++;
        }
        
        $bulkData['rows'] = $rows;
        return response()->json($bulkData);
    }
    
    public function store(Request $request) {
        $request->validate([
            'category_name' => 'required',
            'file' => 'required|image|mimes:jpeg,png,jpg',
        ]);
        if (!is_dir($this->destinationPath)) {
            mkdir($this->destinationPath, 0777, TRUE);                
        }
        // image upload
        $image = $request->file('file');
        $imageName = microtime(true) . "." . $image->getClientOriginalExtension();
        $image->move($this->destinationPath, $imageName);   
        
        Category::create([
            'category_name' => $request->category_name,
            'image' => $imageName,
            'description' => ($request->description) ? $request->description : '',
            'sequence' => 0,
            'date' => date('Y-m-d'),
        ]);
        
        return redirect('category')->with('success', trans('message.category_insert'));
    }
    
    public function update(Request $request) {
        $request->validate([
            'category_name' => 'required'
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
        
        $data['category_name'] = $request->category_name;
        $data['description'] = ($request->description) ? $request->description : '';
        Category::where('id', $id)->update($data);
        return response()->json([
            'error' => false,
            'message' => trans('message.category_update')
        ]);
    }
    
    public function destroy(Request $request) {
        $id = $request->id;
        $image = $request->image;
        if (Category::where('id', $id)->delete()){
            if (file_exists($this->destinationPath . $image)) {
                unlink($this->destinationPath . $image);
            }
            Video::where('category_id', $id)->delete();
            return response()->json([
                'error' => false,
                'message' => trans('message.category_delete')
            ]);
        } else {
            return response()->json([
                'error' => true,
                'message' => trans('message.something_wrong')
            ]);
        }
    }
    
}
