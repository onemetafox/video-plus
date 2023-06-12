@extends('common.master')

@section('title', trans('message.system_update'))

@section('content')  
<div class="pc-container">
    <div class="pcoded-content">
        <div class="row">
            <div class="col-sm-12">
                <div class="card">
                    <div class="card-header">
                        <h5>{{trans('message.system_update')}} <small>{{ trans('message.current_version') .' '. getSettingsByType('system_version') }}</small></h5>
                    </div>
                    <div class="card-body">
                        <form  action="{{url('system-update')}}" class="needs-validation" method="post" novalidate enctype="multipart/form-data">
                            @csrf
                            <div class="form-group row">
                                <div class="col-md-6 col-sm-12">
                                    <label class="form-label">{{trans('message.purchase_code')}}</label>
                                    <input name="purchase_code" type="text" class="form-control" placeholder="{{trans('message.purchase_code')}}" required>
                                </div>
                            </div>
                            <div class="form-group row">
                                <div class="col-md-6 col-sm-12">
                                    <label class="form-label">{{trans('message.upload_zip')}} <small class="text-danger"> {{trans('message.only_zip_allow')}}</small></label>
                                    <input name="file" type="file" accept="application/zip" class="form-control">
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
