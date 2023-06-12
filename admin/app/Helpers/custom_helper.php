<?php

use App\Models\Setting;

function getSettings(){
    $settingList = array();
    $setting = Setting::get();
    foreach ($setting as $row) {
        $settingList[$row->type] = $row->message;
    }
    return $settingList;
}

function getSettingsByType($type = ''){
    $settingList = '';
    $setting = Setting::where('type', $type)->first();    
    if(!empty($setting)){
        $settingList = $setting->message;
    }
    return $settingList;
}

?>