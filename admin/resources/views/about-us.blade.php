@extends('common.master')

@section('title', trans('message.about_us'))

@section('content')  
<div class="pc-container">
    <div class="pcoded-content">
        <div class="row">
            <div class="col-sm-12">
                <div class="card">
                    <div class="card-header">
                        <h5>{{trans('message.about_us')}}  <small>{{ trans('message.about_us_content') }}</small>
                            @php
                                $type1 = str_replace('-', '_', $type);
                            @endphp
                            <a href="{{url('settings') .'/'. $type1}}" target="_blank" class="float-end btn btn-sm btn-theme">{{trans('message.about_us_page')}}</a>
                        </h5>
                    </div>
                    <div class="card-body">
                        <form  action="{{url('settings')}}"  class="needs-validation" method="post" novalidate>
                            @csrf
                            <div class="form-group row">
                                <div class="col-md-12 mb-3">
                                    <input name="type" value="{{$type}}" type="hidden">
                                    <textarea id="message" name="message" class="tox-target">{{$message}}</textarea>
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

@section('js')

<script src="{{url('public/assets/tinymce/tinymce.min.js')}}"></script>

<script type="text/javascript">
   tinymce.init({
        height: "400",
        selector: '#message',
        menubar: 'file edit view formate tools',
        toolbar: [
            'styleselect fontselect fontsizeselect',
            'undo redo | cut copy paste | bold italic | alignleft aligncenter alignright alignjustify',
            'bullist numlist | outdent indent | blockquote autolink | lists |  code'
        ],
        plugins: 'autolink link image lists code'
    });
</script>
@endsection