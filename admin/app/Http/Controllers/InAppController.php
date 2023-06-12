<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\InAppPurchase;

class InAppController extends Controller
{
    public function index() {
        return view('inapp-purchase');
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

        $sql = DB::table('tbl_inapp_list');
        if (isset($_GET['search']) && !empty($_GET['search'])) {
            $search = $_GET['search'];
            $sql->where('id', 'LIKE', "%$search%")->orwhere('type', 'LIKE', "%$search%")->orwhere('name', 'LIKE', "%$search%")->orwhere('product_id', 'LIKE', "%$search%")->orwhere('days', 'LIKE', "%$search%");
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
            $operate = '<a class="'.config('global.EDIT_ICON').'" data-id=' . $row->id . ' data-bs-toggle="modal" data-bs-target="#editDataModal" title="Edit"><i class="fa fa-edit"></i></a>&nbsp;&nbsp;';
            $operate .= '<a class="'.config('global.DELETE_ICON').'" data-id=' . $row->id . '><i class="fa fa-trash"></i></a>';

            $tempRow['count'] = $count;
            $tempRow['id'] = $row->id;
            $tempRow['type'] = $row->type;
            $tempRow['name'] = $row->name;
            $tempRow['product_id'] = $row->product_id;
            $tempRow['days'] = $row->days;
            $tempRow['status1'] = $row->status;
            $tempRow['status'] = ($row->status) ? "<label class='badge rounded-pill bg-success'>".trans('message.active')."</label>" : "<label class='badge rounded-pill bg-danger'>".trans('message.deactive')."</label>";
            $tempRow['operate'] = $operate;
            $rows[] = $tempRow;
            $count++;
        }

        $bulkData['rows'] = $rows;
        return response()->json($bulkData);
    }

    public function store(Request $request) {
        $request->validate([
            'type' => 'required',
            'name' => 'required',
            'product_id' => 'required',
            'days' => 'required',
        ]);          

        InAppPurchase::create([
            'type' => $request->type,
            'name' => $request->name,
            'product_id' => $request->product_id,
            'days' => $request->days,
            'status' => 1
        ]);
        return redirect('inapp-purchase')->with('success', trans('message.inapp_purchase_insert'));
    }

    public function update(Request $request) {
        $request->validate([
            'edit_type' => 'required',
            'name' => 'required',
            'product_id' => 'required',
            'days' => 'required',
        ]);
        $id = $request->edit_id;
        $data['type'] = $request->edit_type;
        $data['name'] = $request->name;
        $data['product_id'] = $request->product_id;
        $data['days'] = $request->days;
        $data['status'] = $request->status;

        InAppPurchase::where('id', $id)->update($data);
        return response()->json([
            'error' => false,
            'message' => trans('message.inapp_purchase_update')
        ]); 
    }

    public function destroy(Request $request) {
        $id = $request->id;
        if (InAppPurchase::where('id', $id)->delete()){
            return response()->json([
                'error' => false,
                'message' => trans('message.inapp_purchase_delete')
            ]);
        } else {
            return response()->json([
                'error' => true,
                'message' => trans('message.something_wrong')
            ]);
        }
    }

}
