#-------------------------------------------
# Globals
#-------------------------------------------

# Rosbridge 
window.connection = null
window.rosbridge_host = "ws://localhost:9090"

# ROS topics for pub/sub
window.topics = {
  ultrasound: "/ultrasound",
}

# Global refs to Highcharts
window.charts = {}


#-------------------------------------------
# Initializers
#-------------------------------------------

$ ->
  init_view_switching()
  init_rosbridge()
  init_fluid_line_pressure_upstream_chart()
  init_fluid_line_pressure_downstream_chart()
  init_fluid_ph_chart()
  init_fluid_temperature_chart()
  init_fluid_tds_chart()
  
init_rosbridge = ->
  window.ros = new ROS()   
  window.ros.on('error', (e) ->
    log('ROS error: ' + e)
  )
  window.ros.connect window.rosbridge_host

#-------------------------------------------
# UI Control
#-------------------------------------------

init_ui = ->
  init_view_switiching()

init_view_switching = ->
  $(".main-nav li a").on 'click', (e) ->
    context = $(e.currentTarget).data('ui-context')
    $(".ui-context").hide()
    $(".ui-context.ui-" + context).show(0,redraw_charts)
    return false
  $("[data-ui-context=dashboard]").click()
    

#-------------------------------------------
# Utility functions
#-------------------------------------------

log = (message) -> 
  if console != undefined
    console.log message


#-------------------------------------------
# Sliders
#-------------------------------------------

$ ->
  $(".slider.led-slider").slider {
    value: 0,
    orientation: "horizontal",
    range: "min",
    min: 0,
    max: 3,
    step: 1,
    change: (event, ui) ->
      if ui.value == 0
        value = "Off"
      else if ui.value == 1
        value = "1/3 power"
      else if ui.value == 2
        value = "2/3 power"
      else if ui.value == 3
        value = "Full power"
      $(event.target).parent().find("span.value").html(value)
      $(event.target).find(".ui-slider-range")
        .removeClass("led-power-0")
        .removeClass("led-power-1")
        .removeClass("led-power-2")
        .removeClass("led-power-3")
        .addClass("led-power-" + ui.value)
  }


#-------------------------------------------
# Charts
#-------------------------------------------

redraw_charts = ->
  $.each window.charts, (i,el) ->
    el.setSize($(el.container).closest(".chart").width(), $(el.container).closest(".chart").height())

init_fluid_ph_chart = ->
  window.charts.ph = new Highcharts.Chart {
    chart: {
      renderTo: 'fluid-chart-ph',
      defaultSeriesType: 'area',
    },
    legend: false,
    title: {
      text: 'pH'
    },
    xAxis: {
      type: 'datetime',
      minRange: 500,
      tickInterval: 5000,
    },
    yAxis: {
      min: 4.5,
      max: 8.5,
      tickInterval: 0.5,
      minPadding: 0.1,
      title: {
        text: "pH",
      }
    },
    series: [{
      name: "pH",
      data: [],
    }]
  }

init_fluid_tds_chart = ->
  window.charts.tds = new Highcharts.Chart {
    chart: {
      renderTo: 'fluid-chart-tds',
      defaultSeriesType: 'area',
    },
    legend: false,
    title: {
      text: 'Total Dissolved Solids'
    },
    xAxis: {
      type: 'datetime',
      minRange: 500,
      tickInterval: 5000,
    },
    yAxis: {
      min: 0,
      max: 2000,
      tickInterval: 500,
      minPadding: 0.1,
      title: {
        text: "ppm",
      }
    },
    series: [{
      name: "TDS",
      data: [],
    }]
  }


init_fluid_temperature_chart = ->
  window.charts.temp = new Highcharts.Chart {
    chart: {
      renderTo: 'fluid-chart-temp',
      defaultSeriesType: 'area',
    },
    legend: false,
    title: {
      text: 'Reservoir Temperature (°C)'
    },
    xAxis: {
      type: 'datetime',
      minRange: 500,
      tickInterval: 5000,
    },
    yAxis: {
      min: 50,
      max: 90,
      tickInterval: 10,
      minPadding: 0.1,
      title: {
        text: "Temp (°C)",
      }
    },
    series: [{
      name: "Temperature",
      data: [],
    }]
  }

init_fluid_line_pressure_upstream_chart = ->
  window.charts.line_pressure_upstream = new Highcharts.Chart {
    chart: {
      renderTo: 'fluid-chart-line-pressure-upstream',
      defaultSeriesType: 'area',
    },
    legend: false,
    title: {
      text: 'Upstream Line Pressure',
    },
    xAxis: {
      type: 'datetime',
      minRange: 500,
      tickInterval: 5000,
      rangeSelector: {
        buttons: [{
          type: 'minute',
          count: 1,
          text: '1m', 
        },{
          type: 'minute',
          count: 5,
          text: '5m', 
        },{
          type: 'minute',
          count: 10,
          text: '10m',
        },{
          type: 'minute',
          count: 30,
          text: '30m',
        },{
          type: 'hour',
          count: 1,
          text: '1h'
        }],
        selected: 1,
      }
    },
    yAxis: {
      min: 0,
      max: 1,
      tickInterval: 0.25,
      minPadding: 0.1,
      title: {
        text: "PSI",
      }
    },
    series: [{
      name: "Line Pressure",
      data: [],
    }]
  },
  subscribe_to_ultrasound() 

init_fluid_line_pressure_downstream_chart = ->
  window.charts.line_pressure_downstream = new Highcharts.Chart {
    chart: {
      renderTo: 'fluid-chart-line-pressure-downstream',
      defaultSeriesType: 'area',
    },
    legend: false,
    title: {
      text: 'Downstream Line Pressure',
    },
    xAxis: {
      type: 'datetime',
      minRange: 500,
      tickInterval: 5000,
      rangeSelector: {
        buttons: [{
          type: 'minute',
          count: 1,
          text: '1m', 
        },{
          type: 'minute',
          count: 5,
          text: '5m', 
        },{
          type: 'minute',
          count: 10,
          text: '10m',
        },{
          type: 'minute',
          count: 30,
          text: '30m',
        },{
          type: 'hour',
          count: 1,
          text: '1h'
        }],
        selected: 1,
      }
    },
    yAxis: {
      min: 0,
      max: 1,
      tickInterval: 0.25,
      minPadding: 0.1,
      title: {
        text: "PSI",
      }
    },
    series: [{
      name: "Line Pressure",
      data: [],
    }]
  },
  subscribe_to_ultrasound() 

#-------------------------------------------
# Subscribers
#-------------------------------------------

subscribe_to_ultrasound = ->
  ultrasound = new window.ros.Topic {
    name        : window.topics.ultrasound,
    messageType : "sensor_msgs/Range"
  }
  ultrasound.subscribe (response) ->
    ultrasound_handler(response)


#-------------------------------------------
# Response callbacks
#-------------------------------------------

ultrasound_handler = (response) ->
  chart = window.charts.line_pressure
  series = chart.series[0]
  if series.data.length > 50
    shift = true
  else
    shift = false
  value = response.range
  series.addPoint [response.header.stamp.secs*1000, value], true, shift
  $(".fluid-line-pressure-value").html(value.toFixed(2))

ph_handler = (response) ->
  chart = window.systems.fluid.charts.ph
  series = chart.series[0]
  if series.data.length > 50
    shift = true
  else
    shift = false
  value = response.range
  series.addPoint [response.header.stamp.secs*1000, value], true, shift
  $(".fluid-ph-value").html(value.toFixed(2))


