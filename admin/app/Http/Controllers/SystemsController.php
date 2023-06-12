<?php

namespace App\Http\Controllers;

use App\Models\Setting;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Artisan;
use ZipArchive;

class SystemsController extends Controller
{
    public function __construct() {
        $this->destinationPath = public_path() .'/images/tmp/';
    }
    
    public function index() {
        return view('system-update');
    }
    
    public function system_update(Request $request) {
        $request->validate([
            'file' => 'required|file|mimes:zip',
            'purchase_code' => 'required',
        ]);
        
        $puchase_code = $request->purchase_code;
        $app_url = (string) url('/');
        $app_url = preg_replace('#^https?://#i', '', $app_url);
        $curl = curl_init();
        curl_setopt_array($curl, array(
            CURLOPT_URL => 'https://wrteam.in/validator/video_plus_validator?purchase_code='.$puchase_code.'&domain_url='.$app_url.'',
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_MAXREDIRS => 10,
            CURLOPT_FOLLOWLOCATION => true,
            CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
            CURLOPT_CUSTOMREQUEST => 'GET',
        ));
        $response = curl_exec($curl);
        curl_close($curl);
        $response = json_decode($response, true);
        if($response['error']){
            return redirect('system-update')->with('error', $response["message"]);
        } else {
            if (!is_dir($this->destinationPath)) {
                mkdir($this->destinationPath, 0777, TRUE);                
            }               
            
            // zip upload
            $zipfile = $request->file('file');
            $fileName = $zipfile->getClientOriginalName();
            $zipfile->move($this->destinationPath, $fileName);   
            
            $target_path = getcwd() . DIRECTORY_SEPARATOR;
            
            $zip = new ZipArchive();
            $filePath = $this->destinationPath . '/' . $fileName;
            $zipStatus = $zip->open($filePath);
            if($zipStatus){
                $zip->extractTo($this->destinationPath);
                $zip->close();
                unlink($filePath);
                
                $ver_file = $this->destinationPath . 'version_info.php';
                $source_path = $this->destinationPath . 'source_code.zip';
                if (file_exists($ver_file) && file_exists($source_path)) {
                    $ver_file1 = $target_path . 'version_info.php';
                    $source_path1 = $target_path . 'source_code.zip';
                    if (rename($ver_file, $ver_file1) && rename($source_path, $source_path1)) {
                        $version_file = require_once ($ver_file1);
                        $current_version = getSettingsByType('system_version');
                        if ($current_version == $version_file['current_version']) {
                            $zip1 = new ZipArchive();
                            $zipFile1 = $zip1->open($source_path1);
                            if ($zipFile1 === true) {
                                $zip1->extractTo($target_path); // change this to the correct site path
                                $zip1->close();
                                
                                Artisan::call('migrate');
                                
                                unlink($source_path1);
                                unlink($ver_file1);
                                
                                $data['category_name'] = $request->category_name;
                                Setting::where('type', 'system_version')->update([
                                    'message' => $version_file['update_version']
                                ]);
                                return redirect('system-update')->with('success', trans('message.system_update_successfully'));
                            } else {
                                unlink($source_path1);
                                unlink($ver_file1);
                                return redirect('system-update')->with('error', trans('message.something_wrong_try_again'));
                            }
                        } else if ($current_version == $version_file['update_version']) {
                            unlink($source_path1);
                            unlink($ver_file1);
                            return redirect('system-update')->with('error', trans('message.system_already_updated'));
                        } else {
                            unlink($source_path1);
                            unlink($ver_file1);
                            return redirect('system-update')->with('error', $current_version .' '.trans('message.your_version_update_nearest'));
                        }
                    } else {
                        return redirect('system-update')->with('error', trans('message.invalid_zip_try_again'));
                    }
                } else {
                    return redirect('system-update')->with('error', trans('message.invalid_zip_try_again'));
                }
            } else {
                return redirect('system-update')->with('error', trans('message.something_wrong_try_again'));
            }
        }
        
    }
}
