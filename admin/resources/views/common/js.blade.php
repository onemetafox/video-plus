<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>

<script src="{{ url('public/assets/js/vendor-all.js') }}" type="text/javascript"></script>

<script src="{{ url('public/assets/js/plugins/bootstrap.min.js') }}" type="text/javascript"></script>

<script src="{{ url('public/assets/js/pcoded.js') }}" type="text/javascript"></script>
<script src="{{ url('public/assets/js/plugins/feather.min.js') }}" type="text/javascript"></script>

<script src="{{ url('public/assets/js/plugins/sweetalert2.all.min.js') }}" type="text/javascript"></script>

<!--lightbox-->
<script src="{{ asset('public/assets/lightbox/js/lightbox.min.js') }}" type="text/javascript"></script>

<!-- Boorstrap Table Js -->
<script src="{{ url('public/assets/bootstrap-table/bootstrap-table.min.js') }}" type="text/javascript"></script>
<script src="{{ url('public/assets/bootstrap-table/fixed-columns/bootstrap-table-fixed-columns.min.js') }}"
    type="text/javascript"></script>
<script src="{{ url('public/assets/bootstrap-table/mobile/bootstrap-table-mobile.min.js') }}" type="text/javascript">
</script>

<script type="text/javascript">
    (function() {
        'use strict';
        window.addEventListener('load', function() {
            // Fetch all the forms we want to apply custom Bootstrap validation styles to
            var forms = document.getElementsByClassName('needs-validation');
            // Loop over them and prevent submission
            var validation = Array.prototype.filter.call(forms, function(form) {
                form.addEventListener('submit', function(event) {
                    if (form.checkValidity() === false) {
                        event.preventDefault();
                        event.stopPropagation();
                    }
                    form.classList.add('was-validated');
                }, false);
            });
        }, false);
    })();
</script>
<script type="text/javascript">
    Toast = Swal.mixin({
        toast: true,
        position: 'top-end',
        showConfirmButton: false,
        timer: 3000,
        timerProgressBar: true,
        didOpen: (toast) => {
            toast.addEventListener('mouseenter', Swal.stopTimer)
            toast.addEventListener('mouseleave', Swal.resumeTimer)
        }
    });
</script>
@if (Session::has('success'))
    <script type="text/javascript">
        Toast.fire({
            icon: 'success',
            title: '{{ Session::get('success') }}'
        });
    </script>
@endif
@if (Session::has('error'))
    <script type="text/javascript">
        Toast.fire({
            icon: 'error',
            title: '{{ Session::get('error') }}'
        });
    </script>
@endif
@if ($errors->any())
    @foreach ($errors->all() as $error)
        <script type='text/javascript'>
            Toast.fire({
                icon: 'error',
                title: '{{ $error }}'
            });
        </script>
    @endforeach
@endif

<script type="text/javascript">
    function successMsg($title) {
        Toast.fire({
            icon: 'success',
            title: $title
        })
    }

    function errorMsg($title) {
        Toast.fire({
            icon: 'error',
            title: $title
        })
    }
</script>

@yield('js')
