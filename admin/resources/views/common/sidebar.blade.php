<nav class="pc-sidebar">
    <div class="navbar-wrapper">
        <div class="m-header">
            <a href="{{url('/')}}" class="b-brand">
                <h3 class="text-white logo logo-lg">{{getSettingsByType('app_name')}}</h3>
                <img src="{{url("public/images").'/'.getSettingsByType('half_logo')}}" alt="logo" class="logo logo-sm">
            </a>
        </div>
        <div class="navbar-content">
            <ul class="pc-navbar">
                <li class="pc-item">
                    <a href="{{url('dashboard')}}" class="pc-link"><span class="pc-micon"><i class="fa fa-home"></i></span><span class="pc-mtext">{{trans('message.dashboard')}}</span></a>
                </li>               
                <li class="pc-item">
                    <a href="{{url('slider')}}" class="pc-link"><span class="pc-micon"><i class="fa fa-sliders-h"></i></span><span class="pc-mtext">{{trans('message.slider')}}</span></a>
                </li>
                <li class="pc-item">
                    <a href="{{url('category')}}" class="pc-link"><span class="pc-micon"><i class="fa fa-cubes"></i></span><span class="pc-mtext">{{trans('message.category')}}</span></a>
                </li>
                <li class="pc-item">
                    <a href="{{url('video')}}" class="pc-link"><span class="pc-micon"><i class="fa fa-video"></i></span><span class="pc-mtext">{{trans('message.video')}}</span></a>
                </li>  
                <li class="pc-item">
                    <a href="{{url('user')}}" class="pc-link"><span class="pc-micon"><i class="fa fa-users"></i></span><span class="pc-mtext">{{trans('message.users')}}</span></a>
                </li>
                <li class="pc-item">
                    <a href="{{url('notification')}}" class="pc-link"><span class="pc-micon"><i class="fa fa-bell"></i></span><span class="pc-mtext">{{trans('message.notification')}}</span></a>
                </li>    
                <li class="pc-item">
                    <a href="{{url('inapp-purchase')}}" class="pc-link"><span class="pc-micon"><i class="fa fa-credit-card"></i></span><span class="pc-mtext">{{trans('message.inapp_purchase')}}</span></a>
                </li>                
                <li class="pc-item pc-hasmenu">
                    <a href="javascript:void(0)" class="pc-link"><span class="pc-micon"><i class="fa fa-cog"></i></span><span class="pc-mtext">{{trans('message.settings')}}</span><span class="pc-arrow"><i data-feather="chevron-right"></i></span></a>
                    <ul class="pc-submenu">
                        <li class="pc-item"><a class="pc-link" href="{{url('system-settings')}}">{{trans('message.system_settings')}}</a></li>
                        <li class="pc-item"><a class="pc-link" href="{{url('about-us')}}">{{trans('message.about_us')}}</a></li>
                        <li class="pc-item"><a class="pc-link" href="{{url('contact-us')}}">{{trans('message.contact_us')}}</a></li>
                        <li class="pc-item"><a class="pc-link" href="{{url('privacy-policy')}}">{{trans('message.privacy_policy')}}</a></li>
                        <li class="pc-item"><a class="pc-link" href="{{url('terms-conditions')}}">{{trans('message.terms_conditions')}}</a></li>
                        <li class="pc-item"><a class="pc-link" href="{{url('notification-setting')}}">{{trans('message.notification_setting')}}</a></li>
                    </ul>
                </li>
                <li class="pc-item">
                    <a href="{{url('system-update')}}" class="pc-link"><span class="pc-micon"><i class="fas fa-cloud-upload-alt"></i></span><span class="pc-mtext">{{trans('message.system_update')}}</span></a>
                </li>  
            </ul>
        </div>
    </div>
</nav>