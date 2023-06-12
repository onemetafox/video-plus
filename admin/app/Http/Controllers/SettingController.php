<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Setting;

class SettingController extends Controller {

    public function __construct() {
        $this->destinationPath = public_path() . '/images/';
    }

    public function view_data(Request $request) {
        $type = $request->type;
        $get_data = Setting::where('type', $type)->first();
        return view('settings', compact('get_data'));
    }

    public function index() {
        $type = last(request()->segments());
        $type1 = str_replace('-', '_', $type);
        $message = Setting::select('message')->where('type', $type1)->pluck('message')->first();
        return view($type, compact('message', 'type'));
    }

    public function settings(Request $request) {
        $request->validate([
            'message' => 'required',
        ]);

        $type = $request->type;
        $type1 = str_replace('-', '_', $type);
        if ($type != '') {
            $message = Setting::where('type', $type1)->first();
            if (empty($message)) {
                Setting::create([
                    'type' => $type1,
                    'message' => $request->message
                ]);
            } else {
                $data['message'] = $request->message;
                Setting::where('type', $type1)->update($data);
            }
            return redirect($type)->with('success', trans('message.setting_update'));
        } else {
            return redirect($type)->with('success', trans('message.something_wrong'));
        }
    }

    public function system_settings() {
        $settings = getSettings();
        return view('system-settings', compact('settings'));
    }

    public function setting_update(Request $request) {
        $request->validate([
            'app_name' => 'required',
            'theme_color' => 'required',
            'app_version_android' => 'required',
            'app_version_ios' => 'required'
        ]);

        $type = [
            'app_name', 'theme_color',
            'app_version_android', 'app_version_ios',
            'force_update', 'app_maintenance',
            'video_payment', 'video_cast', 'screen_shot_recoder',
            'ads_mode', 'android_banner_id', 'android_interstitial_id', 'android_rewarded_id', 'ios_banner_id', 'ios_interstitial_id', 'ios_rewarded_id'
        ];

        foreach ($type as $row) {
            $message = Setting::where('type', $row)->first();
            if (empty($message)) {
                Setting::create([
                    'type' => $row,
                    'message' => ($request->$row != '') ? $request->$row : '' 
                ]);
            } else {
                $data['message'] = ($request->$row != '') ? $request->$row : '' ;
                Setting::where('type', $row)->update($data);
            }
        }

        if ($request->hasFile('full_logo')) {
            $type = 'full_logo';
            $image = $request->file('full_logo');
            $imageName = microtime(true) . "." . $image->getClientOriginalExtension();
            $image->move($this->destinationPath, $imageName);

            $message = Setting::where('type', $type)->first();
            if (empty($message)) {
                Setting::create([
                    'type' => $type,
                    'message' => $imageName
                ]);
            } else {
                if (file_exists($this->destinationPath . $message->message)) {
                    unlink($this->destinationPath . $message->message);
                }
                $data['message'] = $imageName;
                Setting::where('type', $type)->update($data);
            }
        }

        if ($request->hasFile('half_logo')) {
            $type = 'half_logo';
            $image = $request->file('half_logo');
            $imageName = microtime(true) . "." . $image->getClientOriginalExtension();
            $image->move($this->destinationPath, $imageName);

            $message = Setting::where('type', $type)->first();
            if (empty($message)) {
                Setting::create([
                    'type' => $type,
                    'message' => $imageName
                ]);
            } else {
                if (file_exists($this->destinationPath . $message->message)) {
                    unlink($this->destinationPath . $message->message);
                }
                $data['message'] = $imageName;
                Setting::where('type', $type)->update($data);
            }
        }

        return redirect('system-settings')->with('success', trans('message.setting_update'));
    }

}
