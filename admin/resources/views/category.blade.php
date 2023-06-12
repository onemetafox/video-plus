@extends('common.master')

@section('title', trans('message.category'))

@section('content')  
<div class="pc-container">
    <div class="pcoded-content">
        <div class="row">
            <div class="col-md-12 col-sm-12">
                <div class="card">
                    <div class="card-header">
                        <h5>{{trans('message.category_create')}}</h5>

                    </div>
                    <div class="card-body">
                        <form action="{{url('category')}}" class="needs-validation" method="post" novalidate enctype="multipart/form-data">
                            @csrf
                            <div class="form-group row">
                                <div class="col-md-6">
                                    <label class="form-label">{{trans('message.category_name')}}</label>
                                    <input type="text" class="form-control" name="category_name" placeholder="{{trans('message.category_name')}}" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">{{trans('message.image')}}</label>
                                    <input id="file" name="file" type="file" accept="image/*" class="form-control" required>
                                    <p style="display: none" id="img_error_msg" class="badge rounded-pill bg-danger"></p>
                                </div>
                            </div>
                            <div class="form-group row">
                                <div class="col-md-12">
                                    <label class="form-label">{{trans('message.description')}}</label>
                                    <textarea name="description" class="form-control" placeholder="{{trans('message.description')}}"></textarea>
                                </div>
                            </div>
                            <button class="btn btn-theme" type="submit" name="submit">{{trans('message.submit')}}</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
        <div class="row">
            <div class="col-md-12 col-sm-12">
                <div class="card">
                    <div class="card-header">
                        <h5>{{trans('message.category_manage')}}</h5>
                    </div>
                    <div class="card-body">
                        <div id="toolbar">
                            <button class="btn btn-danger btn-sm btn-icon text-white" id="delete_multiple" title="{{ trans('message.multiple_detele_data') }}"><em class='fa fa-trash'></em></button>
                        </div>
                        <table aria-describedby="mydesc" class='table-striped' id="table_list"
                               data-toggle="table" data-url="{{url('categoryList')}}"                            
                               data-click-to-select="true" data-side-pagination="server" 
                               data-pagination="true" data-page-list="[5, 10, 20, 50, 100, 200]" 
                               data-search="true" data-toolbar="#toolbar" 
                               data-show-columns="true" data-show-refresh="true" 
                               data-fixed-columns="true" data-fixed-number="1" data-fixed-right-number="1"
                               data-trim-on-search="false" data-mobile-responsive="true"
                               data-sort-name="id" data-sort-order="desc"  
                               data-pagination-successively-size="3"
                               data-query-params="queryParams">
                            <thead>
                                <tr>
                                    <th scope="col" data-field="state" data-checkbox="true"></th>
                                    <th scope="col" data-field="id" data-sortable="true">{{trans('message.id')}}</th>
                                    <th scope="col" data-field="sequence" data-sortable="true" data-visible="false">{{trans('message.sequence')}}</th>
                                    <th scope="col" data-field="category_name" data-sortable="true">{{trans('message.category')}}</th>
                                    <th scope="col" data-field="image_url" data-sortable="false">{{trans('message.image')}}</th>
                                    <th scope="col" data-field="description" data-sortable="true">{{trans('message.description')}}</th>
                                    <th scope="col" data-field="total_video" data-sortable="false">{{trans('message.total_video')}}</th>
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
<div class="modal fade" id="editDataModal" tabindex="-1" role="dialog" aria-labelledby="myLargeModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title h4">{{trans('message.category_edit')}}</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form id="UpdateFrm" class="needs-validation" method="post" novalidate enctype="multipart/form-data">
                <div class="modal-body">
                    <div class="row">
                        <div class="col-sm-12">
                            @csrf
                            <input type="hidden" name="edit_id" id="edit_id" class="form-control">
                            <input type="hidden" name="image" id="image" class="form-control">
                            <div class="form-group row">
                                <div class="col-md-12">
                                    <label class="form-label">{{trans('message.category_name')}}</label>
                                    <input id="category_name" name="category_name" type="text" class="form-control" placeholder="{{trans('message.category_name')}}" required>
                                </div>
                            </div>
                            <div class="form-group row">
                                <div class="col-md-12 col-sm-12">
                                    <label class="form-label">{{trans('message.image')}} <small> {{trans('message.leave_image')}}</small></label>
                                    <input id="update_file" name="update_file" type="file" accept="image/*" class="form-control">
                                    <p style="display: none" id="up_img_error_msg" class="badge rounded-pill bg-danger"></p>
                                </div>    
                            </div>
                            <div class="form-group row">
                                <div class="col-md-12">
                                    <label class="form-label">{{trans('message.description')}}</label>
                                    <textarea id="description" name="description" class="form-control" placeholder="{{trans('message.description')}}"></textarea>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <div class="row">
                        <div class="col-md-12 text-end">
                            <button type="button" class="btn  btn-secondary" data-bs-dismiss="modal">Close</button>
                            <button class="btn btn-theme" type="submit" name="submit">{{trans('message.submit')}}</button>
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>

@endsection

@section('js')
<script type="text/javascript">
    window.actionEvents = {
        'click .edit-data': function (e, value, row, index) {
            $('#edit_id').val(row.id);
            $('#image').val(row.image);
            $('#category_name').val(row.category_name);
            $('#description').val(row.description);
        }
    };
</script>
<script type="text/javascript">
    $('#UpdateFrm').on('submit', function (e) {
        e.preventDefault();
        var formData = new FormData(this);
        $.ajax({
            method: "POST",
            url: "{{url('category-update')}}",
            data: formData,
            contentType: false,
            processData: false,
            success: function (result) {
                if (result.error) {
                    errorMsg(result.message);
                } else {
                    successMsg(result.message);
                }
                $('#editDataModal').modal('hide');
                $('#UpdateFrm')[0].reset();
                $('#table_list').bootstrapTable('refresh');
            }
        });
    });
</script>
<script type="text/javascript">
    $(document).on('click', '.delete-data', function () {
        if (confirm('{{trans('message.category_delete_confirm_msg')}}')) {
            var id = $(this).data("id");
            var image = $(this).data("image");
            $.ajax({
                url: "{{url('category-delete')}}",
                type: "GET",
                data: {id: id, image: image},
                success: function (result) {
                    if (result.error) {
                        errorMsg(result.message);
                    } else {
                        $('#table_list').bootstrapTable('refresh');
                        successMsg(result.message);
                    }
                }
            });
        }
    });
</script>
<script type="text/javascript">
    $('#delete_multiple').on('click', function (e) {
        table = $('#table_list');
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
                    data: {"_token": "{{ csrf_token() }}", id:ids, table:'tbl_category', is_image:1},
                    beforeSend: function () {
                        delete_button.html('<em class="fa fa-spinner fa-pulse"></em>');
                    },
                    success: function (result) {
                        if (result.error) {
                            errorMsg(result.message);
                        } else {
                            delete_button.html('<em class="fa fa-trash"></em>');
                            $('#table_list').bootstrapTable('refresh');
                            successMsg(result.message);
                        }
                    }
                });
            }
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

    $("#update_file").change(function (e) {
        var file, img;

        if ((file = this.files[0])) {
            img = new Image();
            img.onerror = function () {
                $('#update_file').val('');
                        $('#up_img_error_msg').html('{{trans('message.invalid_image_type')}}');
                $('#up_img_error_msg').show().delay(3000).fadeOut();
            };
            img.src = _URL.createObjectURL(file);
        }
    });
</script>
<script type="text/javascript">
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
@endsection