<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>@yield('title') | {{ getSettingsByType('app_name') }}</title>
        @include('common.head')
    </head>
    <body>
        @include('common.sidebar')
        @include('common.header')
        @yield('content')
        @include('common.js')
    </body>
</html>