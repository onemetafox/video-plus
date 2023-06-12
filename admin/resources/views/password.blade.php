@extends('common.master')

@section('title', trans('message.change_password'))

@section('content')  
<div class="pc-container">
    <div class="pcoded-content">
        <div class="row">
            <div class="col-sm-12">
                <div class="card">
                    <div class="card-header">
                        <h5>{{ trans('message.change_password') }}</h5>
                    </div>
                    <div class="card-body">
                        <form class="needs-validation" method="post" action="{{url('changePassword')}}" novalidate>
                            @csrf
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label" for="old_password">{{ trans('message.old_password') }}</label>
                                    <input type="password" class="form-control" name="old_password" id="old_password"
                                    placeholder="{{ trans('message.old_password') }}" required>
                                </div>
                                <div class="col-sm-6">
                                    <br><br>
                                    <label id="old_status"></label>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label" for="new_password">{{ trans('message.new_password') }}</label>
                                    <input type="password" class="form-control" name="new_password" id="new_password"
                                    placeholder="{{ trans('message.new_password') }}" required>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label" for="confirm_password">{{ trans('message.confirm_password') }}</label>
                                    <input type="password" class="form-control" name="confirm_password" id="confirm_password"
                                    placeholder="{{ trans('message.confirm_password') }}" required>
                                </div>
                            </div>
                            <input class="btn btn-theme" type="submit" value="Submit">                            
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
        $('#old_password').on('blur input', function () {
            var old_password = $(this).val();
            $.ajax({
                type: "GET",
                dataType: "JSON",
                url: "checkPassword",
                data: {old_password: old_password},
                beforeSend: function () {
                    $('#old_status').html('Checking..');
                },
                success: function (result) {
                    if (result == 1) {
                        $('#old_status').html("<i class='fa fa-check-circle fa-2x text-success'></i>");
                        allowsubmit = true;
                    } else {
                        $('#old_status').html("<i class='fa fa-times-circle fa-2x text-danger'></i>");
                        $('#old_password').focus();
                        allowsubmit = false;
                    }
                },
                error: function (result) {
                    $('#old_status').html("Error" + result);
                }
            });
        });
    });
</script>
@endsection