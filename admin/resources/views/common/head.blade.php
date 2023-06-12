<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui">
<meta http-equiv="X-UA-Compatible" content="IE=edge" />

<!-- font css -->
<link rel="stylesheet" href="{{ url('public/assets/fonts/feather.css') }}">
<link rel="stylesheet" href="{{ url('public/assets/fonts/fontawesome.css') }}">
<link rel="stylesheet" href="{{ url('public/assets/fonts/material.css') }}">

<!-- vendor css -->
<link rel="stylesheet" href="{{ url('public/assets/css/style.css') }}">
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">

<!--lightbox-->
<link href="{{ asset('public/assets/lightbox/css/lightbox.min.css') }}" rel="stylesheet" type="text/css">

<!-- Bootstrap Table CSS -->
<link rel="stylesheet" href="{{ url('public/assets/bootstrap-table/bootstrap-table.min.css') }}">
<link rel="stylesheet"
    href="{{ url('public/assets/bootstrap-table/fixed-columns/bootstrap-table-fixed-columns.min.css') }}">

@php
$half_logo = getSettingsByType('half_logo');
@endphp
@if ($half_logo != '')
    <!-- Favicon icon -->
    <link rel="icon" href="{{ url('public/images') . '/' . $half_logo }}" type="image/x-icon">
@endif

@php
$theme_color = getSettingsByType('theme_color');
@endphp
<style>
    :root {
        --theme-color: <?=$theme_color ?>;
    }
</style>
