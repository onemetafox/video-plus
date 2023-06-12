<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Tymon\JWTAuth\Exceptions\JWTException;
use Tymon\JWTAuth\Facades\JWTAuth;
use App\Models\Setting;
use App\Models\User;
use App\Models\Category;
use App\Models\Video;
use App\Models\Playlists;
use App\Models\PlaylistData;
use App\Models\Notifications;
use App\Models\Slider;
use App\Models\InAppPurchase;
use App\Models\InAppUser;
use App\Models\VideoHistory;
use Illuminate\Support\Facades\DB;

class ApiController extends Controller
{

    public function __construct()
    {
        $this->to_date = date('Y-m-d');
    }

    public function set_user_inapp_purchase(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required',
            'inapp_id' => 'required',
        ]);

        if (!$validator->fails()) {
            $inapp_id = $request->inapp_id;
            $user_id = $request->user_id;

            $res = InAppPurchase::where('id', $inapp_id)->first();
            if (!empty($res)) {
                InAppUser::create([
                    'inapp_id' => $inapp_id,
                    'user_id' => $user_id,
                    'date' => $this->to_date,
                    'type' => $res->type,
                    'name' => $res->name,
                    'product_id' => $res->product_id,
                    'days' => $res->days,
                ]);

                $exp_date = date("Y-m-d", strtotime("$this->to_date +$res->days days"));

                $user = User::find($user_id);
                $user->is_subscribe = 1;
                $user->inapp_exp_date = $exp_date;
                $user->update();

                $data = [
                    'error' => false,
                    'message' => 'inapp purchase successfully',
                ];
            } else {
                $data = [
                    'error' => true,
                    'message' => 'No Data Found'
                ];
            }
        } else {
            $data = [
                'error' => true,
                'message' => $validator->errors()->first()

            ];
        }
        return $data;
    }

    public function get_inapp_purchase_list(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'type' => 'required',
            'user_id' => 'required',
        ]);

        if (!$validator->fails()) {
            $res = InAppPurchase::where('type', $request->type)->where('status', 1)->get();

            $users = InAppUser::where('user_id', $request->user_id)->latest("id")->first();

            if (!$res->isEmpty()) {
                for ($i = 0; $i < count($res); $i++) {
                    $res[$i]->is_active = (!empty($users)) ? (($res[$i]->id == $users->inapp_id) ? 1 : 0) : 0;
                }
                $data = [
                    'error' => false,
                    'data' => $res
                ];
            } else {
                $data = [
                    'error' => true,
                    'message' => 'No Data Found'
                ];
            }
        } else {
            $data = [
                'error' => true,
                'message' => $validator->errors()->first()

            ];
        }
        return $data;
    }

    public function get_notification(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required',
        ]);
        if (!$validator->fails()) {
            $user_id = $request->user_id;
            $offset = isset($request->offset) ? $request->offset : 0;
            $limit = isset($request->limit) ? $request->limit : 10;

            $notification = Notifications::whereRaw("find_in_set($user_id,user_id)")->orwhere('users', 'all')->orderBy('id', 'desc')->skip($offset)->take($limit)->get();

            $count =  Notifications::whereRaw("find_in_set($user_id,user_id)")->orwhere('users', 'all')->count();

            if (!$notification->isEmpty()) {
                for ($i = 0; $i < count($notification); $i++) {
                    if ($notification[$i]['image'] != '') {
                        $notification[$i]['image'] = url('public') . '/' . config('global.NOTIFICATION_IMG_PATH') . "/" . $notification[$i]['image'];
                    }
                }
                $data = [
                    'error' => false,
                    'total' => $count,
                    'data' => $notification,
                ];
            } else {
                $data = [
                    'error' => true,
                    'message' => 'No Data Found'
                ];
            }
        } else {
            $data = [
                'error' => true,
                'message' => $validator->errors()->first()

            ];
        }
        return $data;
    }

    public function get_playlist_video(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required',
        ]);
        if (!$validator->fails()) {
            $user_id = $request->user_id;

            $playlist = Playlists::where('user_id', $user_id)->orderBy('id', 'desc')->get();

            $count = count($playlist);
            $playlist_video = Video::select('tbl_playlist_data.id as playlist_video_id', 'tbl_category.category_name', 'tbl_playlist_data.playlist_id', 'tbl_playlist_data.user_id', 'tbl_video.*')
                ->where('tbl_playlist_data.user_id', $user_id)->orderBy('tbl_playlist_data.id', 'desc')
                ->join('tbl_playlist_data', 'tbl_video.id', '=', 'tbl_playlist_data.video_id')->join('tbl_category', 'tbl_video.category_id', '=', 'tbl_category.id')->get();
            for ($k = 0; $k < count($playlist_video); $k++) {
                if ($playlist_video[$k]['image'] != '' && $playlist_video[$k]['image'] != null) {
                    $playlist_video[$k]['image'] = url('public') . '/' . config('global.VIDEO_IMG_PATH') . $playlist_video[$k]['image'];
                }
            }
            $playlist[$count] = [
                'id' => 0,
                'name' => 'All',
                'user_id' => (int)$user_id,
                'date' => '',
                'videos' => $playlist_video
            ];

            if (!$playlist->isEmpty()) {
                for ($i = 0; $i < count($playlist) - 1; $i++) {
                    if ($playlist[$i]->id != 0) {
                        $playlist[$i]['videos'] = Video::select('tbl_playlist_data.id as playlist_video_id', 'tbl_category.category_name', 'tbl_playlist_data.playlist_id', 'tbl_playlist_data.user_id', 'tbl_video.*')
                            ->where('tbl_playlist_data.playlist_id', $playlist[$i]->id)->where('tbl_playlist_data.user_id', $user_id)->orderBy('tbl_playlist_data.id', 'desc')
                            ->join('tbl_playlist_data', 'tbl_video.id', '=', 'tbl_playlist_data.video_id')->join('tbl_category', 'tbl_video.category_id', '=', 'tbl_category.id')->get();
                        for ($j = 0; $j < count($playlist[$i]['videos']); $j++) {
                            if ($playlist[$i]['videos'][$j]['image'] != '' && $playlist[$i]['videos'][$j]['image'] != null) {
                                $playlist[$i]['videos'][$j]['image'] = url('public') . '/' . config('global.VIDEO_IMG_PATH') . $playlist[$i]['videos'][$j]['image'];
                            }
                        }
                    }
                }
                $data = [
                    'error' => false,
                    'data' => $playlist,
                ];
            } else {
                $data = [
                    'error' => true,
                    'message' => 'No Data Found'
                ];
            }
        } else {
            $data = [
                'error' => true,
                'message' => $validator->errors()->first()

            ];
        }
        return $data;
    }

    public function remove_playlist_or_video(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'type' => 'required',
            'type_id' => 'required',
            'user_id' => 'required',
        ]);

        if (!$validator->fails()) {
            $type = $request->type;
            $type_id = $request->type_id;
            $user_id = $request->user_id;
            if ($type == 'playlist') {
                $res = Playlists::where('id', $type_id)->where('user_id', $user_id)->first();
                if (!empty($res)) {
                    Playlists::where('id', $type_id)->where('user_id', $user_id)->delete();
                    PlaylistData::where('playlist_id', $type_id)->where('user_id', $user_id)->delete();
                    $data = [
                        'error' => false,
                        'message' => 'data deleted successfully',
                    ];
                } else {
                    $data = [
                        'error' => true,
                        'message' => 'No Data Found'
                    ];
                }
            } else if ($type == 'video') {
                $res = PlaylistData::where('id', $type_id)->where('user_id', $user_id)->first();
                if (!empty($res)) {
                    PlaylistData::where('id', $type_id)->where('user_id', $user_id)->delete();
                    $data = [
                        'error' => false,
                        'message' => 'data deleted successfully',
                    ];
                } else {
                    $data = [
                        'error' => true,
                        'message' => 'No Data Found'
                    ];
                }
            } else {
                $data = [
                    'error' => true,
                    'message' => 'invalid type'
                ];
            }
        } else {
            $data = [
                'error' => true,
                'message' => $validator->errors()->first()

            ];
        }
        return $data;
    }

    public function store_playlist_video(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'playlist_id' => 'required',
            'video_id' => 'required',
            'user_id' => 'required',
        ]);
        if (!$validator->fails()) {
            $playlist_id = $request->playlist_id;
            $video_id = $request->video_id;
            $user_id = $request->user_id;

            $res = PlaylistData::where('playlist_id', $playlist_id)->where('video_id', $video_id)->where('user_id', $user_id)->first();
            if (empty($res)) {
                $res = PlaylistData::create([
                    'playlist_id' => $playlist_id,
                    'video_id' => $video_id,
                    'user_id' => $user_id,
                    'date' => $this->to_date,
                ]);
                $data = [
                    'error' => false,
                    'message' => 'video save successfully',
                ];
            } else {
                $data = [
                    'error' => true,
                    'message' => 'video already save',
                ];
            }
        } else {
            $data = [
                'error' => true,
                'message' => $validator->errors()->first()

            ];
        }
        return $data;
    }

    public function create_playlist(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required',
            'user_id' => 'required',
        ]);
        if (!$validator->fails()) {
            $user_id = $request->user_id;
            $name = ucwords($request->name);

            $res = Playlists::where('name', $name)->where('user_id', $user_id)->first();
            if (empty($res)) {
                $res = Playlists::create([
                    'name' => $name,
                    'user_id' => $user_id,
                    'date' => $this->to_date,
                ]);
                $data = [
                    'error' => false,
                    'message' => 'playlist create successfully',
                    'id' => $res->id
                ];
            } else {
                $data = [
                    'error' => false,
                    'message' => 'playlist create successfully',
                    'id' => $res->id
                ];
            }
        } else {
            $data = [
                'error' => true,
                'message' => $validator->errors()->first()

            ];
        }
        return $data;
    }

    public function get_video(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'type' => 'required',
            'category_id' => 'required_if:type,==,category',
        ]);
        if (!$validator->fails()) {
            $type = $request->type;

            $offset = isset($request->offset) ? $request->offset : 0;
            $limit = isset($request->limit) ? $request->limit : 10;

            $video = Video::select('tbl_video.*', 'tbl_category.category_name');
            if ($type == 'category') {
                $video = $video->where('category_id', $request->category_id);
            }
            if ($type == 'paid') {
                $video = $video->where('type', 1);
            }
            if ($type == 'free') {
                $video = $video->where('type', 0);
            }
            if (isset($request->search)) {
                $search = $request->search;
                $video = $video->where('tbl_video.title', 'LIKE', "%$search%")->orwhere('tbl_video.video_id', 'LIKE', "%$search%")->orwhere('tbl_video.duration', 'LIKE', "%$search%");
            }
            $video = $video->join('tbl_category', 'tbl_category.id', '=', 'tbl_video.category_id');
            $count = $video->count();
            $res = $video->orderBy('id', 'desc')->skip($offset)->take($limit)->get();

            if (!$res->isEmpty()) {
                for ($i = 0; $i < count($res); $i++) {
                    if ($res[$i]['image'] != '' && $res[$i]['image'] != null) {
                        $res[$i]['image'] = url('public') . '/' . config('global.VIDEO_IMG_PATH') . $res[$i]['image'];
                    }
                }
                $data = [
                    'error' => false,
                    'total' => $count,
                    'data' => $res,
                ];
            } else {
                $data = [
                    'error' => true,
                    'message' => 'No Data Found'
                ];
            }
        } else {
            $data = [
                'error' => true,
                'message' => $validator->errors()->first()

            ];
        }
        return $data;
    }

    public function get_category(Request $request)
    {
        $category = Category::orderBy('id', 'desc')->get();
        if (isset($request->id)) {
            $category = Category::where('id', $request->id)->orderBy('id', 'desc')->get();
        }
        if (!$category->isEmpty()) {
            for ($i = 0; $i < count($category); $i++) {
                if ($category[$i]['image'] != '') {
                    $category[$i]['image'] = url('public') . '/' . config('global.CATEGORY_IMG_PATH') . $category[$i]['image'];
                }
                $video = Video::where('category_id', $category[$i]['id'])->count();
                $category[$i]['total_video'] = $video;
            }
            $data = [
                'error' => false,
                'total' => count($category),
                'data' => $category
            ];
        } else {
            $data = [
                'error' => true,
                'message' => 'No Data Found'
            ];
        }
        return $data;
    }

    public function get_slider(Request $request)
    {
        $slider = Slider::orderBy('id', 'desc')->get();

        if (!$slider->isEmpty()) {
            for ($i = 0; $i < count($slider); $i++) {
                $slider[$i]['image'] = url('public') . '/' . config('global.SLIDER_IMG_PATH') . $slider[$i]['image'];
                if ($slider[$i]['type'] == 'video') {
                    $res = DB::table('tbl_video')->where('id', $slider[$i]['type_id'])->first();
                    if (!empty($res)) {
                        $slider[$i]['category_id'] = $res->category_id;
                        $slider[$i]['video_id'] = $res->video_id;
                        $slider[$i]['type_title'] = $res->title;
                        $slider[$i]['type_description'] = $res->description;
                        $slider[$i]['payment_type'] = $res->type;
                        $slider[$i]['video_type'] = $res->video_type;
                    } else {
                        $slider[$i]['category_id'] = '';
                        $slider[$i]['video_id'] = '';
                        $slider[$i]['type_title'] = '';
                        $slider[$i]['type_description'] = '';
                        $slider[$i]['payment_type'] = 0;
                        $slider[$i]['video_type'] = 0;
                    }
                } else {
                    $slider[$i]['category_id'] = 0;
                    $slider[$i]['video_id'] = '';
                    $slider[$i]['payment_type'] = 0;
                    $res1 = DB::table('tbl_category')->where('id', $slider[$i]['type_id'])->first();
                    if (!empty($res1)) {
                        $slider[$i]['type_title'] = $res1->category_name;
                        $slider[$i]['type_description'] = $res1->description;
                    } else {
                        $slider[$i]['type_title'] = '';
                        $slider[$i]['type_description'] = '';
                    }
                }
            }
            $data = [
                'error' => false,
                'data' => $slider
            ];
        } else {
            $data = [
                'error' => true,
                'message' => 'No Data Found'
            ];
        }
        return $data;
    }

    public function get_user_by_id(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required',
        ]);

        if (!$validator->fails()) {
            $user_id = $request->user_id;

            $this->check_inapp($user_id);

            $user = User::where('id', $user_id)->first();
            if (!empty($user)) {
                if (filter_var($user->profile, FILTER_VALIDATE_URL) === FALSE) {
                    $user->profile = ($user->profile != '') ? url('public') . '/' . config('global.USER_IMG_PATH') . $user->profile : '';
                } else {
                    $user->profile = $user->profile;
                }
                $data = [
                    'error' => false,
                    'data' => $user
                ];
            } else {
                $data = [
                    'error' => true,
                    'message' => "No Data Found"
                ];
            }
        } else {
            $data = [
                'error' => true,
                'message' => $validator->errors()->first()

            ];
        }
        return $data;
    }

    public function profile_image_update(Request $request)
    {

        $validator = Validator::make($request->all(), [
            'user_id' => 'required',
            'profile' => 'required|image|mimes:jpg,png,jpeg,gif,svg',
        ]);

        if (!$validator->fails()) {
            $user = User::where('id', $request->user_id)->get();

            if (!$user->isEmpty()) {
                $user = new User();
                $user = User::find($request->user_id);

                $destinationPath = 'public/' . config('global.USER_IMG_PATH');
                if (!is_dir($destinationPath)) {
                    mkdir($destinationPath, 0777, TRUE);
                }
                // image upload
                $image = $request->file('profile');
                $imageName = microtime(true) . "." . $image->getClientOriginalExtension();
                $image->move($destinationPath, $imageName);

                $user->profile = $imageName;

                $user->update();
                $data = [
                    'error' => false,
                    'message' => 'profile updated successfully'
                ];
            } else {
                $data = [
                    'error' => true,
                    'message' => 'No Data Found'
                ];
            }
        } else {
            $data = [
                'error' => true,
                'message' => $validator->errors()->first()

            ];
        }
        return $data;
    }

    public function profile_update(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required',
        ]);

        if (!$validator->fails()) {
            $user = User::where('id', $request->user_id)->get();

            if (!$user->isEmpty()) {
                $user = new User();
                $user = User::find($request->user_id);
                if (isset($request->name)) {
                    $user->name = $request->name;
                }
                if (isset($request->email)) {
                    $user->email = $request->email;
                }
                if (isset($request->mobile)) {
                    $user->mobile = $request->mobile;
                }
                $user->update();
                $data = [
                    'error' => false,
                    'message' => 'profile updated successfully'
                ];
            } else {
                $data = [
                    'error' => true,
                    'message' => 'No Data Found'
                ];
            }
        } else {
            $data = [
                'error' => true,
                'message' => $validator->errors()->first()

            ];
        }
        return $data;
    }

    public function update_fcm_id(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required',
            'fcm_id' => 'required',
        ]);

        if (!$validator->fails()) {
            $user = User::where('id', $request->user_id)->get();

            if (!$user->isEmpty()) {
                $user = new User();
                $user = $user::find($request->user_id);
                $user->fcm_id = $request->fcm_id;
                $user->update();
                $data = [
                    'error' => false,
                    'message' => 'FCM updated successfully'
                ];
            } else {
                $data = [
                    'error' => true,
                    'message' => 'No Data Found'
                ];
            }
        } else {
            $data = [
                'error' => true,
                'message' => $validator->errors()->first()

            ];
        }
        return $data;
    }

    public function user_signup(Request $request)
    {

        $validator = Validator::make($request->all(), [
            'firebase_id' => 'required',
            'type' => 'required',
            'mobile' => 'required_if:type,==,mobile',
            'email' => 'required_if:type,==,email|required_if:type,==,gmail',
        ]);

        if (!$validator->fails()) {
            $firebase_id = (isset($request->firebase_id)) ? $request->firebase_id : 'guest';
            $type = $request->type;

            $user = User::where('firebase_id', $firebase_id)->get();
            if ($user->isEmpty()) {
                $user1 = new User();
                $user1->is_subscribe = 0;
                $user1->firebase_id = $firebase_id;
                $user1->type = $type;
                $user1->email = ($request->email) ? $request->email : '';
                $user1->mobile = ($request->mobile) ? $request->mobile : '';
                $user1->name = ($request->name) ? $request->name : '';
                $user1->fcm_id = ($request->fcm_id) ? $request->fcm_id : '';
                $user1->profile = ($request->profile) ? $request->profile : '';
                $user1->date_registered = $this->to_date;
                $user1->role = 'user';
                $user1->password = '';
                $user1->status = 1;
                $user1->save();
                $data = [
                    'error' => false,
                    'message' => 'User Register Successfully',
                ];
                $credentials = User::where('firebase_id', $firebase_id)->first();
                try {
                    if (!$token = JWTAuth::fromUser($credentials)) {
                        $data = [
                            'error' => true,
                            'message' => 'Login credentials are invalid.',
                        ];
                    }
                } catch (JWTException $e) {
                    $data = [
                        'error' => true,
                        'message' => 'Could not create token.',
                    ];
                }
                $user2 = new User();
                $user2 = $user2::find($credentials->id);
                $user2->api_token = $token;
                $user2->update();
                $data['data'] = $credentials;
                $data['token'] = $token;
            } else {
                $credentials = User::where('firebase_id', $firebase_id)->first();
                try {
                    if (!$token = JWTAuth::fromUser($credentials)) {
                        $data = [
                            'error' => true,
                            'message' => 'Login credentials are invalid.',
                        ];
                    }
                } catch (JWTException $e) {
                    $data = [
                        'error' => true,
                        'message' => 'Could not create token.',
                    ];
                }
                $this->check_inapp($credentials->id);

                if ($type != 'guest') {
                    $user2 = new User();
                    $user2 = $user2::find($credentials->id);
                    $user2->api_token = $token;
                    $user2->update();
                }
                if (filter_var($credentials->profile, FILTER_VALIDATE_URL) === FALSE) {
                    $credentials->profile = ($credentials->profile != '') ? url('public') . '/' . config('global.USER_IMG_PATH') . $credentials->profile : '';
                } else {
                    $credentials->profile = $credentials->profile;
                }
                $data = [
                    'error' => false,
                    'message' => 'Login Successfully',
                    'token' => ($type == 'guest') ? $credentials->api_token : $token,
                    'data' => $credentials,
                ];
            }
        } else {
            $data = [
                'error' => true,
                'message' => $validator->errors()->first()

            ];
        }
        return $data;
    }

    public function delete_user(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required',
        ]);

        if (!$validator->fails()) {
            $user_id = $request->user_id;
            $user = User::where('id', $user_id)->get();
            if (!$user->isEmpty()) {
                User::find($user_id)->delete();
                InAppUser::where('user_id', $user_id)->delete();
                Playlists::where('user_id', $user_id)->delete();
                PlaylistData::where('user_id', $user_id)->delete();
                $data = [
                    'error' => false,
                    'message' => 'user deleted successfully'
                ];
            } else {
                $data = [
                    'error' => true,
                    'message' => 'No Data Found'
                ];
            }
        } else {
            $data = [
                'error' => true,
                'message' => $validator->errors()->first()

            ];
        }
        return $data;
    }

    public function get_system_settings(Request $request)
    {
        $setting = array();
        $type = [
            'app_name', 'theme_color', 'app_version_android', 'app_version_ios', 'force_update', 'app_maintenance',
            'video_payment', 'video_cast', 'screen_shot_recoder',
            'ads_mode', 'android_banner_id', 'android_interstitial_id', 'android_rewarded_id', 'ios_banner_id', 'ios_interstitial_id', 'ios_rewarded_id'
        ];

        foreach ($type as $key => $row) {
            $res = Setting::select('type', 'message')->where('type', $row)->first();
            $setting[$row] = (!empty($res)) ? $res->message : '';
        }
        if (!empty($setting)) {
            $data = [
                'error' => false,
                'data' => $setting
            ];
        } else {
            $data = [
                'error' => true,
                'message' => 'No Data Found'
            ];
        }
        return $data;
    }

    public function get_settings(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'type' => 'required',
        ]);

        if (!$validator->fails()) {
            $type = $request->type;
            $setting = Setting::select('type', 'message')->where('type', $type)->first();
            if (!empty($setting)) {
                $data = [
                    'error' => false,
                    'data' => $setting
                ];
            } else {
                $data = [
                    'error' => true,
                    'message' => 'No Data Found'
                ];
            }
        } else {
            $data = [
                'error' => true,
                'message' => $validator->errors()->first()

            ];
        }
        return $data;
    }

    function check_inapp($user_id)
    {

        $res = User::where('id', $user_id)->whereNotNull('inapp_exp_date')->first();
        if (!empty($res)) {
            if ($this->to_date > $res->inapp_exp_date) {
                $user = User::find($user_id);
                $user->is_subscribe = 0;
                $user->inapp_exp_date = null;
                $user->update();

                return 0;
            } else {
                return 1;
            }
        } else {
            return 0;
        }
    }
    public function store_video_history(Request $request)
    {

        $validator = Validator::make($request->all(), [
            'duration' => 'required',
            'video_id' => 'required|numeric',
            'user_id' => 'required|numeric',
        ]);
        if (!$validator->fails()) {

            try {

                $duration =  str_replace("\"", "", $request->duration);
                $res = VideoHistory::updateOrCreate(['user_id' => $request->user_id, 'video_id' => $request->video_id], [
                    'video_id' => $request->video_id,
                    'user_id' => $request->user_id,
                    'duration' => $duration,

                ]);

                $views = VideoHistory::where('video_id', $res->video_id)->get();
                $video = Video::find($res->video_id);

                $video->views = count($views);
                $video->save();


                $data = [
                    'error' => false,
                    'message' => 'video History save successfully',
                ];
            } catch (\Throwable $th) {
                $data = [
                    'error' => false,
                    'message' => 'something went wrong',
                ];
            }
        } else {
            $data = [
                'error' => true,
                'message' => $validator->errors()->first()
            ];
        }

        return $data;
    }
    public function get_video_history(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required',

        ]);
        if (!$validator->fails()) {

            $type = $request->type;

            $offset = isset($request->offset) ? $request->offset : 0;
            $limit = isset($request->limit) ? $request->limit : 10;

            $video_history = VideoHistory::select('user_id')->where('user_id', $request->user_id)->first();

            if ($video_history == null) {
                $data = [
                    'error' => true,
                    'message' => 'No Data Found'
                ];
                return $data;
            } else {
                $video = Video::select('tbl_video.*', 'tbl_category.category_name', 'tbl_video_history.user_id', 'tbl_video_history.duration as history_duration')->join('tbl_category', 'tbl_category.id', '=', 'tbl_video.category_id')->join('tbl_video_history', function ($join) use ($video_history) {
                    $join->on('tbl_video_history.video_id', '=', 'tbl_video.id')->where('tbl_video_history.user_id', '=', $video_history->user_id);
                });
            }

            if ($type == 'paid') {
                $video = $video->where('type', 1);
            }
            if ($type == 'free') {
                $video = $video->where('type', 0);
            }
            if (isset($request->search)) {
                $search = $request->search;
                $video = $video->where('tbl_video.title', 'LIKE', "%$search%")->orwhere('tbl_video.video_id', 'LIKE', "%$search%")->orwhere('tbl_video.duration', 'LIKE', "%$search%");
            }

            $count = $video->count();
            $res = $video->orderBy('id', 'asc')->skip($offset)->take($limit)->get();

            if (!$res->isEmpty() || !$video_history->isEmpty() || !$video) {
                for ($i = 0; $i < count($res); $i++) {
                    if ($res[$i]['image'] != '' && $res[$i]['image'] != null) {
                        $res[$i]['image'] = url('public') . '/' . config('global.VIDEO_IMG_PATH') . $res[$i]['image'];
                    }
                }
                $data = [
                    'error' => false,
                    'total' => $count,
                    'data' => $res,
                ];
            } else {
                $data = [
                    'error' => true,
                    'message' => 'No Data Found'
                ];
            }
        } else {
            $data = [
                'error' => true,
                'message' => $validator->errors()->first()

            ];
        }
        return $data;
    }
}
