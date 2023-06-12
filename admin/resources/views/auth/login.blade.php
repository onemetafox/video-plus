<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title> {{ __('Login') }} | {{ getSettingsByType('app_name') }}</title>
    @include('common.head')
</head>
<body>
    
    <div class="auth-wrapper">
        <div class="auth-content">
            <div class="row">
               <div class="alert alert-warning text-center" id="WarningConde">
                Note: If you cannot login here, please close the codecanyon frame by clicking on x Remove Frame button from top right corner on the page or
                <a href="https://videos.wrteam.in/" class="text-danger" target="_blank"> &gt;&gt; Click here &lt;&lt; </a>
              </div>   
           </div>
            <div class="card">
                <div class="row align-items-center text-center">
                    <div class="col-md-12">
                        <div class="card-body">
                            @php
                                $full_logo = getSettingsByType('full_logo');
                            @endphp
                            @if ($full_logo != '')                                
                                <img src="{{url('public/images').'/'.$full_logo}}" alt="" class="img-fluid mb-4">  
                            @else
                                <h5>{{getSettingsByType('app_name')}}</h5>
                            @endif
                            <form method="POST" action="{{ route('login') }}">
                                @csrf
                                <div class="input-group mb-3">
                                    <span class="input-group-text"><i data-feather="mail"></i></span>
                                    <input id="email" type="email" class="form-control @error('email') is-invalid @enderror" name="email" value="admin@gmail.com" required autocomplete="email" autofocus>
                                    
                                    @error('email')
                                    <span class="invalid-feedback" role="alert">
                                        <strong>{{ $message }}</strong>
                                    </span>
                                    @enderror
                                </div>
                                <div class="input-group mb-4">
                                    <span class="input-group-text"><i data-feather="lock"></i></span>
                                    <input id="password" type="password" class="form-control @error('password') is-invalid @enderror" name="password" value="admin123" required autocomplete="current-password">
                                
                                @error('password')
                                <span class="invalid-feedback" role="alert">
                                    <strong>{{ $message }}</strong>
                                </span>
                                @enderror
                                </div>
                                <button type="submit" class="btn btn-block btn-theme mb-4">
                                    {{ __('Login') }}
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    @include('common.js')
</body>
</html>