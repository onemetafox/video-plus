@extends('common.master')

@section('title', trans('message.system_settings'))

@section('content')  
<div class="pc-container">
    <div class="pcoded-content">
        <div class="row">
            <div class="col-sm-12">
                <div class="card">
                    <div class="card-header">
                        <h5>{{trans('message.system_settings')}} <small>{{ trans('message.system_settings_content') }}</small></h5>
                    </div>
                    <div class="card-body">
                        <form  action="{{url('setting-update')}}" class="needs-validation" method="post" novalidate enctype="multipart/form-data">
                            @csrf
                            <div class="form-group row">
                                <div class="col-md-6 col-sm-12">
                                    <label class="form-label">{{trans('message.app_name')}}</label>
                                    <input value="{{isset($settings['app_name']) ? $settings['app_name'] : ''}}" name="app_name" type="text" class="form-control" placeholder="{{trans('message.app_name')}}" required>
                                </div>
                                <div class="col-md-6 col-sm-12">
                                    <label class="form-label">{{trans('message.color')}}</label>
                                    <input name="theme_color" value="{{isset($settings['theme_color']) ? $settings['theme_color'] : ''}}" type="color" required class="form-control"/>
                                </div>
                            </div>
                            <div class="form-group row">
                                <div class="col-md-6 col-sm-12">
                                    <label class="form-label">{{trans('message.full_logo')}} <small> {{trans('message.leave_image')}}</small></label>
                                    <input id="full_logo" name="full_logo" type="file" accept="image/*" class="form-control">
                                    <p style="display: none" id="msg_full_logo" class="badge rounded-pill bg-danger"></p>
                                </div>  
                                <div class="col-md-6 col-sm-12">
                                    <label class="form-label">{{trans('message.half_logo')}} <small> {{trans('message.leave_image')}}</small></label>
                                    <input id="half_logo" name="half_logo" type="file" accept="image/*" class="form-control">
                                    <p style="display: none" id="msg_half_logo" class="badge rounded-pill bg-danger"></p>
                                </div>    
                            </div>
                            
                            <div class="form-group row"> 
                                <div class="col-md-6 col-sm-12">
                                    @if (isset($settings['full_logo']))
                                    <img src="{{url('public/images') .'/'. $settings['full_logo']}}" alt="logo">
                                    @endif
                                </div>
                                <div class="col-md-6 col-sm-12">
                                    @if (isset($settings['half_logo']))
                                    <img src="{{url('public/images') .'/'. $settings['half_logo']}}" alt="logo">
                                    @endif
                                </div>
                            </div>                              
                            
                            <div class="form-group row"> 
                                <div class="col-md-3 col-sm-6">
                                    <label class="form-label">{{trans('message.app_version_android')}}</label>
                                    <input value="{{isset($settings['app_version_android']) ? $settings['app_version_android'] : ''}}" name="app_version_android" type="text" class="form-control" placeholder="{{trans('message.app_version_android')}}" required>
                                </div>
                                <div class="col-md-3 col-sm-6">
                                    <label class="form-label">{{trans('message.app_version_ios')}}</label>
                                    <input value="{{isset($settings['app_version_ios']) ? $settings['app_version_ios'] : ''}}" name="app_version_ios" type="text" class="form-control" placeholder="{{trans('message.app_version_ios')}}" required>
                                </div>
                                <div class="col-md-3 col-sm-6">
                                    <label class="form-label">{{trans('message.force_update')}}</label>
                                    <div class="form-check form-switch custom-switch-v1">
                                        <input id="force_update_btn" name="force_update_btn" type="checkbox" class="form-check-input input-success" {{ (isset($settings['force_update'])) ? (($settings['force_update'] == 1) ? 'checked' : '') : ''}}>
                                        <input type="hidden" id="force_update" name="force_update" value="{{isset($settings['force_update']) ? $settings['force_update'] : 0}}">
                                    </div>
                                </div>
                                <div class="col-md-3 col-sm-6">
                                    <label class="form-label">{{trans('message.app_maintenance')}}</label>
                                    <div class="form-check form-switch custom-switch-v1">
                                        <input id="app_maintenance_btn" name="app_maintenance_btn" type="checkbox" class="form-check-input input-success" {{ (isset($settings['app_maintenance'])) ? (($settings['app_maintenance'] == 1) ? 'checked' : '') : ''}}>
                                        <input type="hidden" id="app_maintenance" name="app_maintenance" value="{{isset($settings['app_maintenance']) ? $settings['app_maintenance'] : 0}}">
                                    </div>
                                </div>
                            </div>
                            <div class="form-group row">
                                <div class="col-md-3 col-sm-6">
                                    <label class="form-label">{{trans('message.video_payment')}}</label>
                                    <div class="form-check form-switch custom-switch-v1">
                                        <input id="video_payment_btn" name="video_payment_btn" type="checkbox" class="form-check-input input-success" {{ (isset($settings['video_payment'])) ? (($settings['video_payment'] == 1) ? 'checked' : '') : ''}}>
                                        <input type="hidden" id="video_payment" name="video_payment" value="{{isset($settings['video_payment']) ? $settings['video_payment'] : 0}}">
                                    </div>
                                </div>
                                <div class="col-md-3 col-sm-6">
                                    <label class="form-label">{{trans('message.video_cast')}}</label>
                                    <div class="form-check form-switch custom-switch-v1">
                                        <input id="video_cast_btn" name="video_cast_btn" type="checkbox" class="form-check-input input-success" {{ (isset($settings['video_cast'])) ? (($settings['video_cast'] == 1) ? 'checked' : '') : ''}}>
                                        <input type="hidden" id="video_cast" name="video_cast" value="{{isset($settings['video_cast']) ? $settings['video_cast'] : 0}}">
                                    </div>
                                </div>
                                <div class="col-md-3 col-sm-6">
                                    <label class="form-label">{{trans('message.screen_shot_recoder')}}</label>
                                    <div class="form-check form-switch custom-switch-v1">
                                        <input id="screen_shot_recoder_btn" name="screen_shot_recoder_btn" type="checkbox" class="form-check-input input-success" {{ (isset($settings['screen_shot_recoder'])) ? (($settings['screen_shot_recoder'] == 1) ? 'checked' : '') : ''}}>
                                        <input type="hidden" id="screen_shot_recoder" name="screen_shot_recoder" value="{{isset($settings['screen_shot_recoder']) ? $settings['screen_shot_recoder'] : 0}}">
                                    </div>
                                </div>
                            </div>
                            <div class="form-group row">
                                <div class="col-md-3 col-sm-6">
                                    <label class="form-label">{{trans('message.ads_mode')}}</label>
                                    <div class="form-check form-switch custom-switch-v1">
                                        <input id="ads_mode_btn" name="ads_mode_btn" type="checkbox" class="form-check-input input-success" {{ (isset($settings['ads_mode'])) ? (($settings['ads_mode'] == 1) ? 'checked' : '') : ''}}>
                                        <input type="hidden" id="ads_mode" name="ads_mode" value="{{isset($settings['ads_mode']) ? $settings['ads_mode'] : 0}}">
                                    </div>
                                </div>
                            </div>
                            <div class="adsgoogle">
                                <div class="form-group row">
                                    <div class="col-md-4 col-sm-12">
                                        <label class="form-label">{{trans('message.android_banner_id')}}</label>
                                        <input value="{{isset($settings['android_banner_id']) ? $settings['android_banner_id'] : ''}}" name="android_banner_id" type="text" class="form-control googleAtt" placeholder="{{trans('message.android_banner_id')}}" required>
                                    </div>
                                    <div class="col-md-4 col-sm-12">
                                        <label class="form-label">{{trans('message.android_interstitial_id')}}</label>
                                        <input value="{{isset($settings['android_interstitial_id']) ? $settings['android_interstitial_id'] : ''}}" name="android_interstitial_id" type="text" class="form-control googleAtt" placeholder="{{trans('message.android_interstitial_id')}}" required>
                                    </div>
                                    <div class="col-md-4 col-sm-12">
                                        <label class="form-label">{{trans('message.android_rewarded_id')}}</label>
                                        <input value="{{isset($settings['android_rewarded_id']) ? $settings['android_rewarded_id'] : ''}}" name="android_rewarded_id" type="text" class="form-control googleAtt" placeholder="{{trans('message.android_rewarded_id')}}" required>
                                    </div>
                                </div>
                                <div class="form-group row">
                                    <div class="col-md-4 col-sm-12">
                                        <label class="form-label">{{trans('message.ios_banner_id')}}</label>
                                        <input value="{{isset($settings['ios_banner_id']) ? $settings['ios_banner_id'] : ''}}" name="ios_banner_id" type="text" class="form-control googleAtt" placeholder="{{trans('message.ios_banner_id')}}" required>
                                    </div>
                                    <div class="col-md-4 col-sm-12">
                                        <label class="form-label">{{trans('message.ios_interstitial_id')}}</label>
                                        <input value="{{isset($settings['ios_interstitial_id']) ? $settings['ios_interstitial_id'] : ''}}" name="ios_interstitial_id" type="text" class="form-control googleAtt" placeholder="{{trans('message.ios_interstitial_id')}}" required>
                                    </div>
                                    <div class="col-md-4 col-sm-12">
                                        <label class="form-label">{{trans('message.ios_rewarded_id')}}</label>
                                        <input value="{{isset($settings['ios_rewarded_id']) ? $settings['ios_rewarded_id'] : ''}}" name="ios_rewarded_id" type="text" class="form-control googleAtt" placeholder="{{trans('message.ios_rewarded_id')}}" required>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="row">
                                <div class="col-md-12 mb-3">
                                    <button class="btn btn-theme" type="submit" name="submit">{{trans('message.submit')}}</button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection

@section('js')

<script type="text/javascript">
    $(document).ready(function () {
        $('.adsgoogle').hide();
        $('.googleAtt').removeAttr('required');

        var ads = $('#ads_mode').val();
        if (ads === '1' || ads === 1) {
            $('.adsgoogle').show();
            $('.googleAtt').attr('required', 'required');
        }
    });
    
    $('#force_update_btn').click(function() {
        if($(this).is(':checked')){
            $("#force_update").val(1);  // checked
        } else {
            $("#force_update").val(0);
        }
    });
    
    $('#app_maintenance_btn').click(function() {
        if($(this).is(':checked')){
            $("#app_maintenance").val(1);  // checked
        } else {
            $("#app_maintenance").val(0);
        }
    });
    
    $('#video_payment_btn').click(function() {
        if($(this).is(':checked')){
            $("#video_payment").val(1);  // checked
        } else {
            $("#video_payment").val(0);
        }
    });
    
    $('#video_cast_btn').click(function() {
        if($(this).is(':checked')){
            $("#video_cast").val(1);  // checked
        } else {
            $("#video_cast").val(0);
        }
    });
    
    $('#screen_shot_recoder_btn').click(function() {
        if($(this).is(':checked')){
            $("#screen_shot_recoder").val(1);  // checked
        } else {
            $("#screen_shot_recoder").val(0);
        }
    });
    
    $('#ads_mode_btn').click(function() {
        if($(this).is(':checked')){
            $("#ads_mode").val(1);  // checked
            $('.adsgoogle').show();
            $('.googleAtt').attr('required', 'required');
        } else {
            $("#ads_mode").val(0);
            $('.adsgoogle').hide();
            $('.googleAtt').removeAttr('required');
        }
    });
    
    var _URL = window.URL || window.webkitURL;
    
    $("#full_logo").change(function (e) {
        var file, img;
        
        if ((file = this.files[0])) {
            img = new Image();
            img.onerror = function () {
                $('#full_logo').val('');
                $('#msg_full_logo').html('{{trans('message.invalid_image_type')}}');
                $('#msg_full_logo').show().delay(3000).fadeOut();
            };
            img.src = _URL.createObjectURL(file);
        }
    });
    
    $("#half_logo").change(function (e) {
        var file, img;
        
        if ((file = this.files[0])) {
            img = new Image();
            img.onerror = function () {
                $('#half_logo').val('');
                $('#msg_half_logo').html('{{trans('message.invalid_image_type')}}');
                $('#msg_half_logo').show().delay(3000).fadeOut();
            };
            img.src = _URL.createObjectURL(file);
        }
    });
</script>

@endsection