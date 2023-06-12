@extends('common.master')

@section('title', trans('message.dashboard'))

@section('content')
    <div class="pc-container">
        <div class="pcoded-content">
            <div class="row">
                <div class="col-xl-3 col-md-6">
                    <div class="card prod-p-card bg-primary">
                        <a href="{{ url('slider') }}">
                            <div class="card-body">
                                <div class="card social-widget-card bg-primary">
                                    <h3 class="text-white m-0">{{ $slider }}</h3>
                                    <span class="m-t-10">Slider</span>
                                    <i class="fa fa-sliders-h"></i>
                                </div>
                            </div>
                        </a>
                    </div>
                </div>
                <div class="col-xl-3 col-md-6">
                    <div class="card prod-p-card bg-success">
                        <a href="{{ url('category') }}">
                            <div class="card-body">
                                <div class="card social-widget-card bg-success">
                                    <h3 class="text-white m-0">{{ $category }}</h3>
                                    <span class="m-t-10">Category</span>
                                    <i class="fa fa-cubes"></i>
                                </div>
                            </div>
                        </a>
                    </div>
                </div>
                <div class="col-xl-3 col-md-6">
                    <div class="card prod-p-card bg-warning">
                        <a href="{{ url('video') }}">
                            <div class="card-body">
                                <div class="card social-widget-card bg-warning">
                                    <h3 class="text-white m-0">{{ $video }}</h3>
                                    <span class="m-t-10">Video</span>
                                    <i class="fa fa-video"></i>
                                </div>
                            </div>
                        </a>
                    </div>
                </div>
                <div class="col-xl-3 col-md-6">
                    <div class="card prod-p-card bg-info">
                        <a href="{{ url('user') }}">
                            <div class="card-body">
                                <div class="card social-widget-card bg-info">
                                    <h3 class="text-white m-0">{{ $users }}</h3>
                                    <span class="m-t-10">User</span>
                                    <i class="fa fa-users"></i>
                                </div>
                            </div>
                        </a>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-xl-6 col-md-12">
                    <div class="card">
                        <div class="card-header">
                            <h5>{{ trans('message.user_registrations') }}</h5>
                        </div>
                        <div class="card-body">
                            <div id="time-chart"></div>
                        </div>
                    </div>
                </div>
                <div class="col-xl-6 col-md-12">
                    <div class="card">
                        <div class="card-header">
                            <h5>{{ trans('message.in_app_purchase_statistics') }}</h5>
                        </div>
                        <div class="card-body">
                            <div id="satisfaction-chart"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection
@section('js')
    <script src="{{ url('public/assets/js/plugins/apexcharts.min.js') }}" type="text/javascript"></script>
    <script type="text/javascript">
        (function() {
            var options = {
                chart: {
                    height: 260,
                    type: 'pie',
                },
                series: [{{ $paid_user }}, {{ $free_user }}],
                labels: ['{{ trans('message.premium_user') }}', '{{ trans('message.free_user') }}'],
                legend: {
                    show: true,
                    offsetY: 50,
                },
                dataLabels: {
                    enabled: true,
                    dropShadow: {
                        enabled: false,
                    }
                },
                theme: {
                    monochrome: {
                        enabled: true,
                        color: '#00000',
                    }
                },
                responsive: [{
                    breakpoint: 768,
                    options: {
                        chart: {
                            height: 320,
                        },
                        legend: {
                            position: 'bottom',
                            offsetY: 0,
                        }
                    }
                }]
            }
            var chart = new ApexCharts(document.querySelector("#satisfaction-chart"), options);
            chart.render();

            var options1 = {
                chart: {
                    height: 245,
                    type: 'line',
                    zoom: {
                        enabled: false
                    },
                    toolbar: {
                        show: false,
                    }
                },
                dataLabels: {
                    enabled: false
                },
                stroke: {
                    width: 3,
                    curve: 'straight',
                },
                xaxis: {
                    categories: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov',
                        'Dec'
                    ],
                },
                colors: ["#00000"],
                series: [{
                    name: '{{ trans('message.statistics') }}',
                    data: {{ $userArr }}
                }],
                grid: {
                    row: {
                        colors: ['#f3f6ff', 'transparent'],
                        opacity: 0.5
                    }
                },
            }

            var chart1 = new ApexCharts(document.querySelector("#time-chart"), options1);
            chart1.render();

        })();
    </script>
@endsection
