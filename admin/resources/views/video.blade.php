@extends('common.master')

@section('title', trans('message.video'))

@section('content')
    <div class="pc-container">
        <div class="pcoded-content">
            <div class="row">
                <div class="col-md-12 col-sm-12">
                    <div class="card">
                        <div class="card-header">
                            <h5>{{ trans('message.video_create') }}</h5>
                        </div>
                        <div class="card-body">
                            <form action="{{ url('video') }}" class="needs-validation" method="post" novalidate
                                enctype="multipart/form-data">
                                @csrf
                                <div class="form-group row">
                                    <div class="col-md-6">
                                        <label class="form-label">{{ trans('message.category') }}</label>
                                        <select name="category_id" class="form-control" required>
                                            <option value="">{{ trans('message.category_select') }}</option>
                                            @foreach ($category as $item)
                                                <option value="{{ $item->id }}">{{ $item->category_name }}</option>
                                            @endforeach
                                        </select>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label">{{ trans('message.title') }}</label>
                                        <input name="title" type="text" class="form-control"
                                            placeholder="{{ trans('message.title') }}" required>
                                    </div>
                                </div>
                                <div class="form-group row">
                                    <div class="col-md-6">
                                        <label class="form-label">{{ trans('message.video_type') }}</label>
                                        <select id="video_type" name="video_type" class="form-control" required>
                                            <option value="">{{ trans('message.video_type_select') }}</option>
                                            <option value="1">{{ trans('message.youtube') }}</option>
                                            <option value="2">{{ trans('message.viemo') }}</option>
                                            <option value="3">{{ trans('message.external_link') }}</option>
                                        </select>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label">{{ trans('message.video_id') }}</label>
                                        <input name="video_id" id="video_id" type="text" class="form-control"
                                            placeholder="{{ trans('message.video_type_select') }}" required>
                                    </div>
                                </div>
                                <div class="form-group row">
                                    <div class="col-md-4">
                                        <label class="form-label">{{ trans('message.image') }}</label>
                                        <input id="file" name="file" type="file" accept="image/*"
                                            class="form-control">
                                        <p style="display: none" id="img_error_msg" class="badge rounded-pill bg-danger">
                                        </p>
                                    </div>
                                    <div class="col-md-4">
                                        <label class="form-label">{{ trans('message.duration') }}</label>
                                        <input name="duration" type="text" class="form-control" placeholder="02:05:00"
                                            required>
                                    </div>
                                    <div class="col-md-4">
                                        <label class="form-label">{{ trans('message.type') }}</label><br>
                                        <div class="form-check-inline">
                                            <input name="type" value="0" type="radio" class="form-check-input"
                                                required>
                                            <label class="form-check-label">{{ trans('message.free') }}</label>
                                        </div>
                                        <div class="form-check-inline">
                                            <input name="type" value="1" type="radio" class="form-check-input"
                                                required>
                                            <label class="form-check-label">{{ trans('message.paid') }}</label>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group row">
                                    <div class="col-md-12">
                                        <label class="form-label">{{ trans('message.description') }}</label>
                                        <textarea name="description" class="form-control" placeholder="{{ trans('message.description') }}"></textarea>
                                    </div>
                                </div>
                                <button class="btn btn-theme" type="submit"
                                    name="submit">{{ trans('message.submit') }}</button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12 col-sm-12">
                    <div class="card">
                        <div class="card-header">
                            <h5>{{ trans('message.video_manage') }}</h5>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-4 col-sm-12">
                                    <select id="filter_category" class="form-control" required>
                                        <option value="">{{ trans('message.category_select') }}</option>
                                        @foreach ($category as $item)
                                            <option value="{{ $item->id }}">{{ $item->category_name }}</option>
                                        @endforeach
                                    </select>
                                </div>
                            </div>
                            <div id="toolbar">
                                <button class="btn btn-danger btn-sm btn-icon text-white" id="delete_multiple"
                                    title="{{ trans('message.multiple_detele_data') }}"><em
                                        class='fa fa-trash'></em></button>
                            </div>
                            <table aria-describedby="mydesc" class='table-striped' id="table_list" data-toggle="table"
                                data-url="{{ url('videoList') }}" data-click-to-select="true"
                                data-side-pagination="server" data-pagination="true"
                                data-page-list="[5, 10, 20, 50, 100, 200]" data-search="true" data-toolbar="#toolbar"
                                data-show-columns="true" data-show-refresh="true" data-fixed-columns="true"
                                data-fixed-number="1" data-fixed-right-number="1" data-trim-on-search="false"
                                data-mobile-responsive="true" data-sort-name="id" data-sort-order="desc"
                                data-pagination-successively-size="3" data-query-params="queryParams">
                                <thead>
                                    <tr>
                                        <th scope="col" data-field="state" data-checkbox="true"></th>
                                        <th scope="col" data-field="id" data-sortable="true">
                                            {{ trans('message.id') }}</th>
                                        <th scope="col" data-field="category_id" data-sortable="true"
                                            data-visible="false">{{ trans('message.category_id') }}</th>
                                        <th scope="col" data-field="category_name" data-sortable="true">
                                            {{ trans('message.category') }}</th>
                                        <th scope="col" data-field="title" data-sortable="true">
                                            {{ trans('message.title') }}</th>
                                        <th scope="col" data-field="video_type1" data-sortable="false">
                                            {{ trans('message.video_type') }}</th>
                                        <th scope="col" data-field="video_id" data-sortable="true">
                                            {{ trans('message.video_id') }}</th>
                                        <th scope="col" data-field="image_url" data-sortable="false">
                                            {{ trans('message.image') }}</th>
                                        <th scope="col" data-field="duration" data-sortable="true">
                                            {{ trans('message.duration') }}</th>
                                        <th scope="col" data-field="type" data-sortable="false">
                                            {{ trans('message.type') }}</th>
                                        <th scope="col" data-field="description" data-sortable="false">
                                            {{ trans('message.description') }}</th>
                                        <th scope="col" data-field="views" data-sortable="false">
                                            {{ trans('message.views') }}</th>

                                        <th scope="col" data-field="operate" data-sortable="false"
                                            data-events="actionEvents">{{ trans('message.action') }}</th>
                                    </tr>
                                </thead>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="modal fade" id="editDataModal" tabindex="-1" role="dialog" aria-labelledby="myLargeModalLabel"
        aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title h4">{{ trans('message.video_edit') }}</h5>
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
                                    <div class="col-md-6">
                                        <label class="form-label">{{ trans('message.category') }}</label>
                                        <select id="category_id" name="category_id" class="form-control" required>
                                            <option value="">{{ trans('message.category_select') }}</option>
                                            @foreach ($category as $item)
                                                <option value="{{ $item->id }}">{{ $item->category_name }}</option>
                                            @endforeach
                                        </select>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label">{{ trans('message.title') }}</label>
                                        <input id="title" name="title" type="text" class="form-control"
                                            placeholder="{{ trans('message.title') }}" required>
                                    </div>
                                </div>
                                <div class="form-group row">
                                    <div class="col-md-6">
                                        <label class="form-label">{{ trans('message.video_type') }}</label>
                                        <select id="edit_video_type" name="video_type" class="form-control" required>
                                            <option value="">{{ trans('message.video_type_select') }}</option>
                                            <option value="1">{{ trans('message.youtube') }}</option>
                                            <option value="2">{{ trans('message.viemo') }}</option>
                                            <option value="3">{{ trans('message.external_link') }}</option>
                                        </select>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label">{{ trans('message.video_id') }}</label>
                                        <input id="edit_video_id" name="video_id" type="text" class="form-control"
                                            placeholder="placeholder="{{ trans('message.video_type_select') }}"" required>
                                    </div>
                                </div>
                                <div class="form-group row">
                                    <div class="col-md-4">
                                        <label class="form-label">{{ trans('message.image') }} <small>
                                                {{ trans('message.leave_image') }}</small></label>
                                        <input id="update_file" name="update_file" type="file" accept="image/*"
                                            class="form-control">
                                        <p style="display: none" id="up_img_error_msg"
                                            class="badge rounded-pill bg-danger"></p>
                                    </div>
                                    <div class="col-md-4">
                                        <label class="form-label">{{ trans('message.duration') }}</label>
                                        <input id="duration" name="duration" type="text" class="form-control"
                                            placeholder="02:05:00" required>
                                    </div>
                                    <div class="col-md-4">
                                        <label class="form-label">{{ trans('message.type') }}</label><br>
                                        <div class="form-check-inline">
                                            <input name="edit_type" value="0" type="radio"
                                                class="form-check-input" required>
                                            <label class="form-check-label">{{ trans('message.free') }}</label>
                                        </div>
                                        <div class="form-check-inline">
                                            <input name="edit_type" value="1" type="radio"
                                                class="form-check-input" required>
                                            <label class="form-check-label">{{ trans('message.paid') }}</label>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group row">
                                    <div class="col-md-12">
                                        <label class="form-label">{{ trans('message.description') }}</label>
                                        <textarea id="description" name="description" class="form-control"
                                            placeholder="{{ trans('message.description') }}"></textarea>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <div class="row">
                            <div class="col-md-12 text-end">
                                <button type="button" class="btn  btn-secondary" data-bs-dismiss="modal">Close</button>
                                <button class="btn btn-theme" type="submit"
                                    name="submit">{{ trans('message.submit') }}</button>
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
        $(document).on('change', '#video_type', function() {
            var video_type = $(this).val();
            if (video_type == 1) {
                $('#file').removeAttr('required');
                $('#video_id').attr('placeholder', '1y_kfWUCFDQ');
            } else if (video_type == 2) {
                $('#file').removeAttr('required');
                $('#video_id').attr('placeholder', '395212534');
            } else if (video_type == 3) {
                $('#file').attr('required', 'required');
                $('#video_id').attr('placeholder', '{{ trans('message.external_link') }}');
            }
        });
        $(document).on('change', '#edit_video_type', function() {
            var edit_video_type = $(this).val();
            if (edit_video_type == 1) {
                $('#edit_video_id').attr('placeholder', '1y_kfWUCFDQ');
            } else if (edit_video_type == 2) {
                $('#edit_video_id').attr('placeholder', '395212534');
            } else if (edit_video_type == 3) {
                $('#edit_video_id').attr('placeholder', '{{ trans('message.external_link') }}');
            }
        });
    </script>
    <script type="text/javascript">
        window.actionEvents = {
            'click .edit-data': function(e, value, row, index) {
                $('#image').val(row.image);
                $('#edit_id').val(row.id);
                $('#category_id').val(row.category_id);
                $('#title').val(row.title);
                $('#edit_video_id').val(row.video_id);
                $('#duration').val(row.duration);
                $('#description').val(row.description);
                var edit_video_type = row.video_type;
                $('#edit_video_type').val(edit_video_type);
                if (edit_video_type == 1) {
                    $('#edit_video_id').attr('placeholder', '1y_kfWUCFDQ');
                } else if (edit_video_type == 2) {
                    $('#edit_video_id').attr('placeholder', '395212534');
                } else if (edit_video_type == 3) {
                    $('#edit_video_id').attr('placeholder', '{{ trans('message.external_link') }}');
                }

                $("input[name=edit_type][value=1]").prop('checked', true);
                if (row.type1 == 0) {
                    $("input[name=edit_type][value=0]").prop('checked', true);
                }
            }
        };
    </script>
    <script type="text/javascript">
        $('#UpdateFrm').on('submit', function(e) {
            e.preventDefault();
            var formData = new FormData(this);
            $.ajax({
                method: "POST",
                url: "{{ url('video-update') }}",
                data: formData,
                contentType: false,
                processData: false,
                success: function(result) {
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
        $(document).on('click', '.delete-data', function() {
            if (confirm('Are you sure? Want to delete ?')) {
                var id = $(this).data("id");
                var image = $(this).data("image");
                $.ajax({
                    url: "{{ url('video-delete') }}",
                    type: "GET",
                    data: {
                        id: id,
                        image: image
                    },
                    success: function(result) {
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
        $('#filter_category').on('change', function(e) {
            $('#table_list').bootstrapTable('refresh');
        });

        function queryParams(p) {
            return {
                "category_id": $('#filter_category').val(),
                sort: p.sort,
                order: p.order,
                offset: p.offset,
                limit: p.limit,
                search: p.search
            };
        }
    </script>
    <script type="text/javascript">
        $('#delete_multiple').on('click', function(e) {
            table = $('#table_list');
            delete_button = $('#delete_multiple');
            selected = table.bootstrapTable('getSelections');
            ids = "";
            $.each(selected, function(i, e) {
                ids += e.id + ",";
            });
            ids = ids.slice(0, -1);
            if (ids == "") {
                alert('{{ trans('message.please_select_some_data') }}');
            } else {
                if (confirm('{{ trans('message.are_you_sure_delete_selected_data') }}')) {
                    $.ajax({
                        url: "{{ url('multiple-delete') }}",
                        type: "POST",
                        data: {
                            "_token": "{{ csrf_token() }}",
                            id: ids,
                            table: 'tbl_video',
                            is_image: 0
                        },
                        beforeSend: function() {
                            delete_button.html('<em class="fa fa-spinner fa-pulse"></em>');
                        },
                        success: function(result) {
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

        $("#file").change(function(e) {
            var file, img;

            if ((file = this.files[0])) {
                img = new Image();
                img.onerror = function() {
                    $('#file').val('');
                    $('#img_error_msg').html('{{ trans('message.invalid_image_type') }}');
                    $('#img_error_msg').show().delay(3000).fadeOut();
                };
                img.src = _URL.createObjectURL(file);
            }
        });

        $("#update_file").change(function(e) {
            var file, img;

            if ((file = this.files[0])) {
                img = new Image();
                img.onerror = function() {
                    $('#update_file').val('');
                    $('#up_img_error_msg').html('{{ trans('message.invalid_image_type') }}');
                    $('#up_img_error_msg').show().delay(3000).fadeOut();
                };
                img.src = _URL.createObjectURL(file);
            }
        });
    </script>
@endsection
