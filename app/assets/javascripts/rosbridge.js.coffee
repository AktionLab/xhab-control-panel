window.connection = null
window.rosbridge_host = "ws://localhost:9090"
window.topics = {}
window.topics.ultrasound = "/ultrasound"

window.systems = {
  fluid: {
    charts: {
      line_pressure: null
    }
  },
}

$ ->
  init_rosbridge()
  init_fluid_line_pressure_chart()

log = (message) -> 
  if console != undefined
    console.log message

init_handlers = ->
  ultrasound_handler()

init_rosbridge = ->
  window.ros = new ROS()
   
  window.ros.on('error', (e) ->
    log('ROS error: ' + e)
  )
 
  window.ros.connect window.rosbridge_host

init_fluid_line_pressure_chart = ->
  window.systems.fluid.charts.line_pressure = new Highcharts.Chart {
    chart: {
      renderTo: 'fluid-chart-line-pressure',
      defaultSeriesType: 'area',
    },
    title: {
      text: 'Line Pressure',
    },
    xAxis: {
      type: 'datetime',
      minRange: 500,
      title: {
        text: 'Time', 
      },
      tickInterval: 10000,
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
        text: "Pressure (psi)",
      }
    },
    series: [{
      name: "Line Pressure",
      data: [],
    }]
  },
  subscribe 

ultrasound_handler = (response) ->
  log(response)
  chart = window.systems.fluid.charts.line_pressure
  log(chart)
  series = chart.series[0]
  if series.data.length > 50
    shift = true
  else
    shift = false
  series.addPoint [response.header.stamp.secs*1000, response.range], true, shift
 
subscribe = ->
  ultrasound = new window.ros.Topic {
    name        : window.topics.ultrasound,
    messageType : "sensor_msgs/Range"
  }
  ultrasound.subscribe (response) ->
    ultrasound_handler(response)
