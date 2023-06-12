@extends('common.master')

@section('title', trans('message.notification'))

@section('content')  
<div class="pc-container">
    <div class="pcoded-content">
        <div class="row">
            <div class="col-md-6 col-sm-12">
                <div class="card">
                    <div class="card-header">
                        <h5>{{trans('message.notification_create')}}</h5>
                    </div>
                    <div class="card-body">
                        <form action="{{url('notification')}}" class="needs-validation" method="post" novalidate enctype="multipart/form-data">
                            @csrf
                            <textarea id="user_id" name="user_id" style="display: none"></textarea>
                            <textarea id="fcm_id" name="fcm_id" style="display: none"></textarea>
                            <div class="form-group row">
                                <div class="col-md-12">
                                    <label class="form-label">{{trans('message.select_user')}}</label>
                                    <select id="users" name="users" class="form-control" required>
                                        <option value="all">{{trans('message.all')}}</option>
                                        <option value="selected">{{trans('message.selected_only')}}</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group row">
                                <div class="col-md-12">
                                    <label class="form-label">{{trans('message.type')}}</label>
                                    <select id="type" name="type" class="form-control" required>
                                        <option value="default">{{trans('message.default')}}</option>
                                        <option value="category">{{trans('message.category')}}</option>
                                        <option value="video">{{trans('message.video')}}</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group row" id="category" style="display: none">
                                <div class="col-md-12">
                                    <label class="form-label">{{trans('message.category')}}</label>
                                    <select id="category_id" name="category_id" class="form-control">
                                        <option value="">{{trans('message.category_select')}}</option>
                                        @foreach($category as $cate)
                                        <option value="{{$cate->id}}">{{$cate->category_name}}</option>
                                        @endforeach
                                    </select>
                                </div>
                            </div>
                            <div class="form-group row" id="video" style="display: none">
                                <div class="col-md-12">
                                    <label class="form-label">{{trans('message.video')}}</label>
                                    <select id="video_id" name="video_id" class="form-control">
                                        <option value="">{{trans('message.video_select')}}</option>
                                        @foreach($video as $row)
                                        <option value="{{$row->id}}">{{$row->title}}</option>
                                        @endforeach
                                    </select>
                                </div>
                            </div>
                            <div class="form-group row">
                                <div class="col-md-12">
                                    <label class="form-label">{{trans('message.title')}}</label>
                                    <input name="title" type="text" class="form-control" placeholder="{{trans('message.title')}}" required>                                    
                                </div>
                            </div>
                            <div class="form-group row">
                                <div class="col-md-12">
                                    <label class="form-label">{{trans('message.message')}}</label>
                                    <textarea name="message" class="form-control" placeholder="{{trans('message.message')}}" required></textarea>
                                </div>
                            </div>
                            <div class="form-group row">
                                <div class="col-md-12">
                                    <div class="form-check">
                                        <input id="include_image" name="include_image" type="checkbox" class="form-check-input">
                                        <label class="form-check-label">{{trans('message.include_image')}}</label>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group row" id="show_image" style="display: none">
                                <div class="col-md-12">
                                    <label class="form-label">{{trans('message.image')}}</label>
                                    <input id="file" name="file" type="file" accept="image/*" class="form-control">
                                    <p style="display: none" id="img_error_msg" class="badge rounded-pill bg-danger"></p>
                                </div>
                            </div>

                            <button class="btn btn-theme" type="submit" name="submit">{{trans('message.submit')}}</button>
                        </form>
                    </div>
                </div>
            </div>
            <div class="col-md-6 col-sm-12">
                <div class="card">
                    <div class="card-header">
                        <h5>{{trans('message.user_list')}}</h5>
                    </div>
                    <div class="card-body">                        
                        <table aria-describedby="mydesc" class='table-striped' id="users_list"
                               data-toggle="table" data-url="{{url('userList')}}"                            
                               data-click-to-select="true" data-side-pagination="server" 
                               data-pagination="true" data-page-list="[5, 10, 20, 50, 100, 200]" 
                               data-search="true" data-show-columns="true" data-show-refresh="true" 
                               data-fixed-columns="true" data-fixed-number="1" data-fixed-right-number="1"
                               data-trim-on-search="false" data-mobile-responsive="true" data-maintain-selected="true"
                               data-sort-name="id" data-sort-order="desc"  
                               data-pagination-successively-size="3" data-query-params="queryParams_1">
                            <thead>
                                <tr>
                                    <th scope="col" data-field="state" data-checkbox="true"></th>
                                    <th scope="col" data-field="id" data-sortable="true">{{trans('message.id')}}</th>
                                    <th scope="col" data-field="name" data-sortable="true">{{trans('message.name')}}</th>
                                    <th scope="col" data-field="email" data-sortable="true">{{trans('message.email')}}</th>
                                    <th scope="col" data-field="mobile" data-sortable="true">{{trans('message.mobile')}}</th>
                                    <th scope="col" data-field="status" data-visible="false" data-sortable="false">{{trans('message.status')}}</th>
                                </tr>
                            </thead>
                        </table>
                    </div>
                </div>
            </div>
        </div>
        <div class="row">
            <div class="col-md-12 col-sm-12">
                <div class="card">
                    <div class="card-header">
                        <h5>{{trans('message.notification_manage')}}</h5>
                    </div>
                    <div class="card-body">
                        <div id="toolbar">
                            <button class="btn btn-danger btn-sm btn-icon text-white" id="delete_multiple" title="{{ trans('message.multiple_detele_data') }}"><em class='fa fa-trash'></em></button>
                        </div>
                        <table aria-describedby="mydesc" class='table-striped' id="table_list1"
                               data-toggle="table" data-url="{{url('notificationList')}}"                            
                               data-click-to-select="true" data-side-pagination="server" 
                               data-pagination="true" data-page-list="[5, 10, 20, 50, 100, 200]" 
                               data-search="true" data-toolbar="#toolbar" 
                               data-show-columns="true" data-show-refresh="true" 
                               data-fixed-columns="true" data-fixed-number="1" data-fixed-right-number="1"
                               data-trim-on-search="false" data-mobile-responsive="true"
                               data-sort-name="id" data-sort-order="desc"  
                               data-pagination-successively-size="3">
                            <thead>
                                <tr>
                                    <th scope="col" data-field="state" data-checkbox="true"></th>
                                    <th scope="col" data-field="id" data-sortable="true">{{trans('message.id')}}</th>
                                    <th scope="col" data-field="title" data-sortable="true">{{trans('message.title')}}</th>
                                    <th scope="col" data-field="message" data-sortable="true">{{trans('message.message')}}</th>
                                    <th scope="col" data-field="image_url" data-sortable="false">{{trans('message.image')}}</th>
                                    <th scope="col" data-field="type" data-sortable="true">{{trans('message.type')}}</th>
                                    <th scope="col" data-field="users" data-sortable="true">{{trans('message.users')}}</th>
                                    <th scope="col" data-field="operate" data-sortable="false" data-events="actionEvents">{{trans('message.action')}}</th>
                                </tr>
                            </thead>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>


@endsection

@section('js')
<script type="text/javascript">
    table = $('#users_list');
    var fcm_list = [];
    var user_list = [];
    $(table).on('check.bs.table  uncheck.bs.table', function (e, row) {
        var fcm_id = row.fcm_id;
        var user_id = row.id;
        if (e.type == 'check') {
            fcm_list.push(fcm_id);
            user_list.push(user_id);
        } else {
            var fcm_index = fcm_list.indexOf(fcm_id);
            if (fcm_index > -1) {
                fcm_list.splice(fcm_index, 1);
            }
            var user_index = user_list.indexOf(user_id);
            if (user_index > -1) {
                user_list.splice(user_index, 1);
            }
        }
        $('textarea#fcm_id').val(fcm_list);
        $('textarea#user_id').val(user_list);
    });
</script>
<script type="text/javascript">
    $('#type').on('change', function () {
        var type = $(this).val();
        if (type == 'category') {
            $('#category').show();
            $('#category_id').attr('required', 'required');
            $('#video_id').removeAttr('required');
            $('#video').hide();
        } else if (type == 'video') {
            $('#video').show();
            $('#video_id').attr('required', 'required');
            $('#category_id').removeAttr('required');
            $('#category').hide();
        }
    });
    $("#include_image").change(function () {
        if (this.checked) {
            $('#show_image').show('fast');
            $('#file').attr('required', 'required');
        } else {
            $('#file').val('');
            $('#file').removeAttr('required');
            $('#show_image').hide('fast');
        }
    });
</script>
<script type="text/javascript">
    window.actionEvents = {};
</script>

<script type="text/javascript">
    $(document).on('click', '.delete-data', function () {
        if (confirm('Are you sure? Want to delete ?')) {
            var id = $(this).data("id");
            var image = $(this).data("image");
            $.ajax({
                url: "{{url('notification-delete')}}",
                type: "GET",
                data: {id: id, image: image},
                success: function (result) {
                    if (result.error) {
                        errorMsg(result.message);
                    } else {
                        $('#table_list1').bootstrapTable('refresh');
                        successMsg(result.message);
                    }
                }
            });
        }
    });
</script>

<script type="text/javascript">
    var _URL = window.URL || window.webkitURL;

    $("#file").change(function (e) {
        var file, img;

        if ((file = this.files[0])) {
            img = new Image();
            img.onerror = function () {
                $('#file').val('');
                $('#img_error_msg').html('{{trans('message.invalid_image_type')}}');
                $('#img_error_msg').show().delay(3000).fadeOut();
            };
            img.src = _URL.createObjectURL(file);
        }
    });
</script>
<script type="text/javascript">
    function queryParams_1(p) {
        return {
            "status": $('#filter_status').val(),
            sort: p.sort,
            order: p.order,
            offset: p.offset,
            limit: p.limit,
            search: p.search
        };
    }
    function queryParams(p) {
        return {
            sort: p.sort,
            order: p.order,
            offset: p.offset,
            limit: p.limit,
            search: p.search
        };
    }
</script>
<script type="text/javascript">
    $('#delete_multiple').on('click', function (e) {
        table = $('#table_list1');
        delete_button = $('#delete_multiple');
        selected = table.bootstrapTable('getSelections');        
        ids = "";
        $.each(selected, function (i, e) {
            ids += e.id + ",";
        });
        ids = ids.slice(0, -1);
        if (ids == "") {
            alert('{{trans('message.please_select_some_data')}}');
        } else {
            if (confirm('{{trans('message.are_you_sure_delete_selected_data')}}')) {
                $.ajax({
                    url: "{{url('multiple-delete')}}",
                    type: "POST",                
                    data: {"_token": "{{ csrf_token() }}", id:ids, table:'tbl_notification', is_image:1},
                    beforeSend: function () {
                        delete_button.html('<em class="fa fa-spinner fa-pulse"></em>');
                    },
                    success: function (result) {
                        if (result.error) {
                            errorMsg(result.message);
                        } else {
                            delete_button.html('<em class="fa fa-trash"></em>');
                            $('#table_list1').bootstrapTable('refresh');
                            successMsg(result.message);
                        }
                    }
                });
            }
        }
    });
</script>
@endsection