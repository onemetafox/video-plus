<div class="loader-bg">
    <div class="loader-track">
        <div class="loader-fill"></div>
    </div>
</div>
<div class="pc-mob-header pc-header">
    <div class="pcm-logo">
        <img src="{{ url('public/images') . '/' . getSettingsByType('half_logo') }}" alt="logo" class="logo logo-lg">
    </div>
    <div class="pcm-toolbar">
        <a href="javascript:void(0)" class="pc-head-link" id="mobile-collapse">
            <div class="hamburger hamburger--arrowturn">
                <div class="hamburger-box">
                    <div class="hamburger-inner"></div>
                </div>
            </div>
        </a>
        <a href="javascript:void(0)" class="pc-head-link" id="header-collapse">
            <i data-feather="more-vertical"></i>
        </a>
    </div>
</div>

<header class="pc-header">
    <div class="header-wrapper">
        <div class="m-header d-flex align-items-center">
            <a class="pc-head-link me-0" href="javascript:void(0)" id="vertical-nav-toggle">
                <i class="material-icons-two-tone">vertical_split</i>
            </a>
            <h5><span class="badge rounded-pill bg-danger">Modification in demo version is not allowed</span></h5>
        </div>
        <div class="ms-auto">
            <ul class="list-unstyled">
                <li class="dropdown pc-h-item">
                    <a class="pc-head-link dropdown-toggle arrow-none me-0" data-bs-toggle="dropdown"
                        href="javascript:void(0)" role="button" aria-haspopup="false" aria-expanded="false">
                        <img src="{{ url('public/images/user.jpg') }}" alt="user-image" class="user-avtar">
                        <span>
                            <span class="user-name">{{ Auth::User()->name }}</span>
                        </span>
                    </a>
                    <div class="dropdown-menu dropdown-menu-end pc-h-dropdown">
                        <a href="{{ url('resetpassword') }}" class="dropdown-item">
                            <i class="material-icons-two-tone">cached</i>
                            <span>{{ trans('message.change_password') }}</span>
                        </a>
                        <a href="{{ route('logout') }}" class="dropdown-item">
                            <i class="material-icons-two-tone">chrome_reader_mode</i>
                            <span>{{ trans('message.logout') }}</span>
                        </a>
                    </div>
                </li>
            </ul>
        </div>
    </div>
</header>
