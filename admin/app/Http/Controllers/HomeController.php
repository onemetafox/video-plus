<?php

namespace App\Http\Controllers;

use App\Models\Category;
use App\Models\Slider;
use App\Models\User;
use App\Models\Video;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;

class HomeController extends Controller
{

    /**
     * Show the application dashboard.
     *
     * @return \Illuminate\Contracts\Support\Renderable
     */
    public function index()
    {
        $slider = Slider::count();
        $category = Category::count();
        $video = Video::count();
        $users = User::where('role', 'user')->count();
        $free_user = User::where('role', 'user')->where('is_subscribe', 0)->count();
        $paid_user = User::where('role', 'user')->where('is_subscribe', 1)->count();

        $res = User::select('id', 'date_registered')->where('role', 'user')->get()->groupBy(function ($date) {
            return Carbon::parse($date->date_registered)->format('m'); // grouping by months
        });

        $usermcount = [];
        $userArr = [];

        foreach ($res as $key => $value) {
            $usermcount[(int)$key] = count($value);
        }

        for ($i = 1; $i <= 12; $i++) {
            if (!empty($usermcount[$i])) {
                $userArr[$i] = $usermcount[$i];
            } else {
                $userArr[$i] = 0;
            }
        }
        $userArr = array_values($userArr);
        $userArr = json_encode($userArr);
        return view('dashboard', compact('slider', 'category', 'video', 'users', 'free_user', 'paid_user', 'userArr'));
    }

    public function login()
    {
        if (Auth::user()) {
            return redirect('dashboard');
        } else {
            return view('auth.login');
        }
    }

    public function multiple_delete(Request $request)
    {
        $table = $request->table;
        $id = $request->id;
        $is_image = $request->is_image;
        $res = DB::table($table)->whereIn('id', explode(',', $id))->get();
        if ($is_image) {
            $path = array(
                'tbl_category' => public_path() . '/' . config('global.CATEGORY_IMG_PATH'),
                'tbl_notification' => public_path() . '/' . config('global.NOTIFICATION_IMG_PATH'),
            );
            foreach ($res as $image) {
                if (isset($image->image) && file_exists($path[$table] . $image->image) && $image->image != "") {
                    unlink($path[$table] . $image->image);
                }
            }
        }
        if (DB::table($table)->whereIn('id', explode(',', $id))->delete()) {
            return response()->json([
                'error' => false,
                'message' => trans('multiple_delete')
            ]);
        } else {
            return response()->json([
                'error' => true,
                'message' => trans('something_wrong')
            ]);
        }
    }

    public function user()
    {
        return view('user');
    }

    public function updateUser(Request $request)
    {
        $request->validate([
            'status' => 'required'
        ]);

        $id = $request->edit_id;

        $data['status'] = $request->status;
        User::where('id', $id)->update($data);
        return response()->json([
            'error' => false,
            'message' => trans('message.user_insert')
        ]);
    }

    public function userList()
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

        $sql = DB::table('users');
        $sql->where('role', 'user');
        if (isset($_GET['search']) && !empty($_GET['search'])) {
            $search = $_GET['search'];
            $sql->where('id', 'LIKE', "%$search%")->orwhere('email', 'LIKE', "%$search%")->orwhere('mobile', 'LIKE', "%$search%")->orwhere('name', 'LIKE', "%$search%");
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
            'email' => 'far fa-envelope-open',
            'gmail' => 'fab fa-google-plus-square text-danger',
            'fb' => 'fab fa-facebook-square text-primary',
            'mobile' => 'fa fa-phone-square',
            'apple' => 'fab fa-apple'
        );

        foreach ($res as $row) {
            if (filter_var($row->profile, FILTER_VALIDATE_URL) === FALSE) {
                $image = (!empty($row->profile)) ? 'public/' . config('global.USER_IMG_PATH') . $row->profile : '';
            } else {
                $image = $row->profile;
            }
            $image = 'public/images/user.jpg';
            $operate = '<a class="' . config('global.EDIT_ICON') . '" data-id=' . $row->id . ' data-bs-toggle="modal" data-bs-target="#editDataModal" title="Edit"><i class="fa fa-edit"></i></a>&nbsp;&nbsp;';

            $tempRow['profile'] = $row->profile;
            $tempRow['count'] = $count;
            $tempRow['id'] = $row->id;
            $tempRow['name'] = $row->name;
            $tempRow['email'] = 'xyz@gmail.com'; //$row->email;
            $tempRow['mobile'] = 'XXX-XX-XXXX';
            $tempRow['type'] = $row->type;
            $tempRow['fcm_id'] = $row->fcm_id;
            $tempRow['type'] = (isset($row->type) && $row->type != '') ? '<em class="' . $icon[trim($row->type)] . ' fa-2x"></em>' : '<em class="' . $icon['email'] . ' fa-2x"></em>';
            $tempRow['status1'] = $row->status;
            $tempRow['status'] = ($row->status) ? "<label class='badge rounded-pill bg-success'>" . trans('message.active') . "</label>" : "<label class='badge rounded-pill bg-danger'>" . trans('message.deactive') . "</label>";
            $tempRow['profile_url'] = ($image != '') ? '<a href="' . $image . '" data-lightbox="Images"><img src="' . $image . '" height=50, width=50 ></a>' : '';
            $tempRow['date_registered'] = $row->date_registered;
            $tempRow['operate'] = $operate;
            $rows[] = $tempRow;
            $count++;
        }

        $bulkData['rows'] = $rows;
        return response()->json($bulkData);
    }

    public function resetpassword()
    {
        return view('password');
    }

    public function checkPassword(Request $request)
    {
        $old_password = $request->old_password;
        $password = User::where('id', Auth::id())->first();
        if (Hash::check($old_password, $password->password)) {
            return response()->json(1);
        } else {
            return response()->json(0);
        }
    }

    public function changePassword(request $request)
    {
        $id = Auth::id();
        $request->validate([
            'old_password' => 'required',
            'new_password' => 'required|min:8',
            'confirm_password' => 'required|same:new_password',
        ]);
        $data['password'] = Hash::make($request->new_password);
        User::where('id', $id)->update($data);
        return redirect('resetpassword')->with('success', 'Password Change Successfully..');
    }

    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->flush();
        $request->session()->regenerate();
        return redirect('/');
    }
}
