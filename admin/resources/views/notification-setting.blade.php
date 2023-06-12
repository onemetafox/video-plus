@extends('common.master')

@section('title', trans('message.notification_setting'))

@section('content')  
<div class="pc-container">
    <div class="pcoded-content">
        <div class="row">
            <div class="col-sm-12">
                <div class="card">
                    <div class="card-header">
                        <h5>{{trans('message.notification_setting')}}  <small>{{ trans('message.notification_setting_content') }}</small></h5>
                    </div>
                    <div class="card-body">
                        <form  action="{{url('settings')}}"  class="needs-validation" method="post" novalidate>
                            @csrf
                            <div class="row">
                                <div class="col-md-6 col-sm-10 col-md-offset-2 mb-3">
                                    <label class="form-label">{{trans('message.fcm_server_key')}}</label>
                                    <input name="type" value="{{$type}}" type="hidden">
                                    <textarea id="message" name="message" class="form-control" rows="5">{{$message}}</textarea>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-sm-10 col-md-offset-2 mb-3">
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