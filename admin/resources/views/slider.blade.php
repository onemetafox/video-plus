@extends('common.master')

@section('title', trans('message.slider'))

@section('content')  
<div class="pc-container">
    <div class="pcoded-content">
        <div class="row">
            <div class="col-md-12 col-sm-12">
                <div class="card">
                    <div class="card-header">
                        <h5>{{trans('message.slider_create')}}</h5>
                    </div>
                    <div class="card-body">
                        <form action="{{url('slider')}}" class="needs-validation" method="post" novalidate enctype="multipart/form-data">
                            @csrf
                            <div class="form-group row">
                                <div class="col-md-6">
                                    <label class="form-label">{{trans('message.image')}}</label>
                                    <input id="file" name="file" type="file" accept="image/*" class="form-control" required>
                                    <p style="display: none" id="img_error_msg" class="badge rounded-pill bg-danger"></p>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">{{trans('message.type')}}</label>
                                    <select id="type" name="type" class="form-control" required>
                                        <option value="">{{trans('message.select_type')}}</option>
                                        <option value="category">{{trans('message.category')}}</option>
                                        <option value="video">{{trans('message.video')}}</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group row">
                                <div class="col-md-12" id="category" style="display: none">
                                    <label class="form-label">{{trans('message.category')}}</label>
                                    <select id="category_id" name="category_id" class="form-control">
                                        <option value="">{{trans('message.category_select')}}</option>
                                        @foreach($category as $cate)
                                        <option value="{{$cate->id}}">{{$cate->category_name}}</option>
                                        @endforeach
                                    </select>
                                </div>
                                <div class="col-md-12" id="video" style="display: none">
                                    <label class="form-label">{{trans('message.video')}}</label>
                                    <select id="video_id" name="video_id" class="form-control">
                                        <option value="">{{trans('message.video_select')}}</option>
                                        @foreach($video as $row)
                                        <option value="{{$row->id}}">{{$row->title}}</option>
                                        @endforeach
                                    </select>
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
                        <h5>{{trans('message.slider_manage')}}</h5>
                    </div>
                    <div class="card-body">
                        <table aria-describedby="mydesc" class='table-striped' id="table_list"
                               data-toggle="table" data-url="{{url('sliderList')}}"                            
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
                                    <th scope="col" data-field="id" data-sortable="true">{{trans('message.id')}}</th>
                                    <th scope="col" data-field="image_url" data-sortable="false">{{trans('message.image')}}</th>
                                    <th scope="col" data-field="type" data-sortable="true">{{trans('message.type')}}</th>
                                    <th scope="col" data-field="type_name" data-sortable="false">{{trans('message.title')}}</th>
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
                <h5 class="modal-title h4">{{trans('message.slider_edit')}}</h5>
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
                                <div class="col-md-12 col-sm-12">
                                    <label class="form-label">{{trans('message.image')}} <small> {{trans('message.leave_image')}}</small></label>
                                    <input id="update_file" name="update_file" type="file" accept="image/*" class="form-control">
                                    <p style="display: none" id="up_img_error_msg" class="badge rounded-pill bg-danger"></p>
                                </div>    
                            </div>
                            <div class="form-group row">
                                <div class="col-md-12">
                                    <label class="form-label">{{trans('message.type')}}</label>
                                    <select id="edit_type" name="type" class="form-control" required>
                                        <option value="">{{trans('message.select_type')}}</option>
                                        <option value="category">{{trans('message.category')}}</option>
                                        <option value="video">{{trans('message.video')}}</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group row">
                                <div class="col-md-12" id="edit_category" style="display: none">
                                    <label class="form-label">{{trans('message.category')}}</label>
                                    <select id="edit_category_id" name="edit_category_id" class="form-control">
                                        <option value="">{{trans('message.category_select')}}</option>
                                        @foreach($category as $cate)
                                        <option value="{{$cate->id}}">{{$cate->category_name}}</option>
                                        @endforeach
                                    </select>
                                </div>
                                <div class="col-md-12" id="edit_video" style="display: none">
                                    <label class="form-label">{{trans('message.video')}}</label>
                                    <select id="edit_video_id" name="edit_video_id" class="form-control">
                                        <option value="">{{trans('message.video_select')}}</option>
                                        @foreach($video as $row)
                                        <option value="{{$row->id}}">{{$row->title}}</option>
                                        @endforeach
                                    </select>
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
            $('#edit_type').val(row.type);            
            var type = row.type;
            var type_id = row.type_id;
            if (type == 'category') {
                $('#edit_category').show();
                $('#edit_category_id').attr('required', 'required');
                $('#edit_video_id').removeAttr('required');
                $('#edit_video').hide();
                $('#edit_category_id').val(type_id)
            } else if (type == 'video') {
                $('#edit_video').show();
                $('#edit_video_id').attr('required', 'required');
                $('#edit_category_id').removeAttr('required');
                $('#edit_category').hide();
                $('#edit_video_id').val(type_id)
            }
        }
    };
</script>
<script type="text/javascript">
    $('#UpdateFrm').on('submit', function (e) {
        e.preventDefault();
        var formData = new FormData(this);
        $.ajax({
            method: "POST",
            url: "{{url('slider-update')}}",
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
        if (confirm('Are you sure? Want to delete ?')) {
            var id = $(this).data("id");
            var image = $(this).data("image");
            $.ajax({
                url: "{{url('slider-delete')}}",
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

    $('#edit_type').on('change', function () {
        var edit_type = $(this).val();
        console.log(edit_type);
        if (edit_type == 'category') {
            $('#edit_category').show();
            $('#edit_category_id').attr('required', 'required');
            $('#edit_video_id').removeAttr('required');
            $('#edit_video').hide();
        } else if (edit_type == 'video') {
            $('#edit_video').show();
            $('#edit_video_id').attr('required', 'required');
            $('#edit_category_id').removeAttr('required');
            $('#edit_category').hide();
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
@endsection