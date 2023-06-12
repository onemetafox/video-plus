@extends('common.master')

@section('title', trans('message.inapp_purchase'))

@section('content')  
<div class="pc-container">
    <div class="pcoded-content">
        <div class="row">
            <div class="col-md-12 col-sm-12">
                <div class="card">
                    <div class="card-header">
                        <h5>{{trans('message.inapp_purchase_create')}}</h5>

                    </div>
                    <div class="card-body">
                        <form action="{{url('inapp-purchase')}}" class="needs-validation" method="post" novalidate enctype="multipart/form-data">
                            @csrf
                            <div class="form-group row">
                                <div class="col-md-6">
                                    <label class="form-label">{{trans('message.name')}}</label>
                                    <input type="text" class="form-control" name="name" placeholder="{{trans('message.name')}}" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">{{trans('message.product_id')}}</label>
                                    <input type="text" class="form-control" name="product_id" placeholder="{{trans('message.product_id')}}" required>                                  
                                </div>
                            </div>
                            <div class="form-group row">
                                <div class="col-md-6">
                                    <label class="form-label">{{trans('message.type')}}</label><br>
                                    <div class="form-check-inline">
                                        <input name="type" value="android" type="radio" class="form-check-input" required>  
                                        <label class="form-check-label">{{trans('message.android')}}</label>                                  
                                    </div>
                                    <div class="form-check-inline">
                                        <input name="type" value="ios" type="radio" class="form-check-input" required>  
                                        <label class="form-check-label">{{trans('message.ios')}}</label>                                  
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">{{trans('message.days')}}</label>
                                    <input type="number" class="form-control" name="days" placeholder="{{trans('message.days')}}" required>                                  
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
                        <h5>{{trans('message.inapp_purchase_manage')}}</h5>
                    </div>
                    <div class="card-body">
                        <table aria-describedby="mydesc" class='table-striped' id="table_list"
                               data-toggle="table" data-url="{{url('inappPurchaseList')}}"                            
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
                                    <th scope="col" data-field="name" data-sortable="true">{{trans('message.name')}}</th>
                                    <th scope="col" data-field="product_id" data-sortable="false">{{trans('message.product_id')}}</th>
                                    <th scope="col" data-field="type" data-sortable="true">{{trans('message.type')}}</th>
                                    <th scope="col" data-field="days" data-sortable="true">{{trans('message.days')}}</th>
                                    <th scope="col" data-field="status" data-sortable="false">{{trans('message.status')}}</th>
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
                <h5 class="modal-title h4">{{trans('message.inapp_purchase_edit')}}</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form id="UpdateFrm" class="needs-validation" method="post" novalidate enctype="multipart/form-data">
                <div class="modal-body">
                    <div class="row">
                        <div class="col-sm-12">
                            @csrf
                            <input type="hidden" name="edit_id" id="edit_id" class="form-control">
                            <div class="form-group row">
                                <div class="col-md-12">
                                    <label class="form-label">{{trans('message.name')}}</label>
                                    <input type="text" id="name" class="form-control" name="name" placeholder="{{trans('message.name')}}" required>
                                </div>
                            </div>
                            <div class="form-group row">
                                <div class="col-md-12">
                                    <label class="form-label">{{trans('message.product_id')}}</label>
                                    <input type="text" id="product_id" class="form-control" name="product_id" placeholder="{{trans('message.product_id')}}" required>                                  
                                </div>
                            </div>
                            <div class="form-group row">
                                <div class="col-md-12">
                                    <label class="form-label">{{trans('message.type')}}</label><br>
                                    <div class="form-check-inline">
                                        <input name="edit_type" value="android" type="radio" class="form-check-input" required>  
                                        <label class="form-check-label">{{trans('message.android')}}</label>                                  
                                    </div>
                                    <div class="form-check-inline">
                                        <input name="edit_type" value="ios" type="radio" class="form-check-input" required>  
                                        <label class="form-check-label">{{trans('message.ios')}}</label>                                  
                                    </div>
                                </div>
                            </div>
                            <div class="form-group row">
                                <div class="col-md-12">
                                    <label class="form-label">{{trans('message.days')}}</label>
                                    <input type="number" id="days" class="form-control" name="days" placeholder="{{trans('message.days')}}" required>                                  
                                </div>
                            </div>
                            <div class="form-group row">
                                <div class="col-md-12">
                                    <label class="form-label">{{trans('message.status')}}</label><br>
                                    <div class="form-check-inline">
                                        <input name="status" value="1" type="radio" class="form-check-input" required>  
                                        <label class="form-check-label">{{trans('message.active')}}</label>                                  
                                    </div>
                                    <div class="form-check-inline">
                                        <input name="status" value="0" type="radio" class="form-check-input" required>  
                                        <label class="form-check-label">{{trans('message.deactive')}}</label>                                  
                                    </div>                                    
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
            $('#name').val(row.name);
            $('#product_id').val(row.product_id);            
            $('#days').val(row.days);
            $("input[name=edit_type][value=ios]").prop('checked', true);
            if (row.type == 'android') {
                $("input[name=edit_type][value=android]").prop('checked', true);
            }
            $("input[name=status][value=1]").prop('checked', true);
            if (row.status1 == 0) {
                $("input[name=status][value=0]").prop('checked', true);
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
            url: "{{url('inapp-purchase-update')}}",
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
        if (confirm('Are you sure? Want to delete ? All related data will also be deleted')) {
            var id = $(this).data("id");
            var image = $(this).data("image");
            $.ajax({
                url: "{{url('inapp-purchase-delete')}}",
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