#-------------------------------------------
# Globals
#-------------------------------------------

# Rosbridge 
window.ros_master_ip = "23.23.182.122"
window.connection = null
window.rosbridge_host = "ws://#{window.ros_master_ip}:9090"

# ROS topics for pub/sub
window.topics = {
  temperature:          "/data/fluid/temperature",
  control_joint_angles: "/control/arm/joint_angles",
  data_joint_angles:    "/data/arm/joint_angles",
}

# Global refs to Highcharts
window.charts = {}


#-------------------------------------------
# Initializers
#-------------------------------------------

$ ->
  init_view_switching()
  init_rosbridge()
  #init_fluid_line_pressure_upstream_chart()
  #init_fluid_line_pressure_downstream_chart()
  #init_fluid_ph_chart()
  init_fluid_temperature_chart()
  #init_fluid_tds_chart()
  #init_arm_camera()
  init_mjpegcanvas()
  init_publish_to_joint_angles()

init_rosbridge = ->
  window.ros = new ROS()   
  window.ros.on('error', (e) ->
    log('ROS error: ' + e)
  )
  window.ros.connect window.rosbridge_host

#-------------------------------------------
# Streaming Video
#-------------------------------------------
init_mjpegcanvas = ->
  mjpeg = new MjpegCanvas {
    host : window.ros_master_ip,
    topic : '/gscam/image_raw',
    canvasID : 'arm-cam',
    width : 320,
    height : 240
  }

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
  $(".slider#joint-slider0").slider {
    value: 0,
    orientation: "vertical",
    range: "min",
    min: -113,
    max: 113,
    step: 0.5,
    slide: (event, ui) ->
      joint_index = $(event.target).data("joint")
      rotate_plan_joint(joint_index,ui.value)
      $("span#joint#{joint_index}-value").html(ui.value)
  }

  $(".slider#joint-slider1").slider {
    value: 0,
    orientation: "vertical",
    range: "min",
    min: -134.6,
    max: 129.9,
    step: 0.1,
    slide: (event, ui) ->
      joint_index = $(event.target).data("joint")
      rotate_plan_joint(joint_index,ui.value)
      $("span#joint#{joint_index}-value").html(ui.value)
  }

  $(".slider#joint-slider2").slider {
    value: 0,
    orientation: "vertical",
    range: "min",
    min: -102.9,
    max: 104.7,
    step: 0.1,
    slide: (event, ui) ->
      joint_index = $(event.target).data("joint")
      rotate_plan_joint(joint_index,ui.value)
      $("span#joint#{joint_index}-value").html(ui.value)
  }

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
      $(event.target).parent().find("span.value").html("")
      led_index = $(event.target).data('led-index')
      led_level = ui.value / 3
      if window.lights_glow[led_index] != undefined
        window.lights_glow[led_index].remove()
      if led_level > 0
        window.lights_glow[led_index] = window.lights[led_index].glow {
          color: "#fff",
          width: led_level*35,
          opacity: led_level*0.85,
          fill: true,
        }

      $(event.target).find(".ui-slider-range")
        .removeClass("led-power-0")
        .removeClass("led-power-1")
        .removeClass("led-power-2")
        .removeClass("led-power-3")
        .addClass("led-power-" + ui.value)
  }

#-------------------------------------------
# Soil Sensor Arm
#-------------------------------------------
$ ->
  sensor_arm_width = $("#soil-sensor-arm").parent().width
  sensor_arm_height = $("#soil-sensor-arm").parent().height
  
  window.sensor_gui = Raphael("soil-sensor-arm", 200, 250)

  window.sensor_gui.setStart()

  probe = window.sensor_gui.rect(0,5,100,6)
  probe.attr "fill", "#4444ff"
 
  arm = window.sensor_gui.rect(10,0,10,150)
  arm.attr "fill", "#555"

  window.sensor_arm = window.sensor_gui.setFinish()

  $("button#insert-probe").click ->
    window.sensor_arm.animate({transform: "r90,15,150"}, 1000) 
 
  $("button#remove-probe").click ->
    window.sensor_arm.animate({transform: "r0,15,150"}, 1000) 
 
#-------------------------------------------
# Lights
#-------------------------------------------
$ ->
  light_paper_width = 318
  light_paper_height = 318
  center_x_pos = light_paper_width/2
  center_y_pos = light_paper_width/2
  led_radius = 40
  pot_radius = 30
  base_plate_radius = light_paper_width/2
  PI = Math.PI

  window.eps_gui = Raphael("raphael-lights-overhead", light_paper_width, light_paper_height)
  
  # base plate
  base_plate = window.eps_gui.circle center_x_pos, center_y_pos, base_plate_radius
  base_plate.attr "fill", "#555"

  # lights & pots
  window.lights = window.eps_gui.set()
  window.lights_glow = window.eps_gui.set()
  window.pots = window.eps_gui.set()
  for i in [0..4]
    angle = (2*PI/5)*i - 0.5*PI
    x_pos = Math.cos(angle)*0.4*(light_paper_width - 2*led_radius) + 0.5*light_paper_width
    y_pos = Math.sin(angle)*0.4*(light_paper_height - 2*led_radius) + 0.5*light_paper_height
    x_pos_label = Math.cos(angle)*0.5*(light_paper_width - 2*led_radius) + 0.5*light_paper_width
    y_pos_label = Math.sin(angle)*0.5*(light_paper_height - 2*led_radius) + 0.5*light_paper_height
    circle = window.eps_gui.circle x_pos, y_pos, led_radius
    circle.attr("stroke", "#fff")
    circle.attr("fill-opacity", 0.75)
    window.lights.push(circle)
    
    pot = window.eps_gui.circle x_pos, y_pos, pot_radius
    pot.attr("stroke", "#000")
    pot.attr("fill", "#000")
    pot.attr("fill-opacity", 0.5)
    window.pots.push(pot)
    
    window.eps_gui.print(x_pos_label, y_pos_label, "L#{i}", window.eps_gui.getFont("Arial"))

  $("button#rotate-pots-clockwise").click ->
    log "rotate CW"
    window.pots.animate({transform: "r10,#{center_x_pos},#{center_y_pos}"}, 1000) 

  $("button#rotate-pots-counterclockwise").click ->
    log "rotate CCW"
    window.pots.animate({transform: "r-10,#{center_x_pos},#{center_y_pos}"}, 1000) 


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
  window.charts.temperature = new Highcharts.Chart {
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
      minRange: 10,
      tickInterval: 10000,
    },
    yAxis: {
      min: -1.5,
      max: 1.5,
      tickInterval: 0.5,
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
  subscribe_to_temperature()

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
  }
  subscribe_to_temperature() 

init_fluid_line_pressure_downstream_chart = ->
  window.charts.line_pressure_downstream = new Highcharts.Chart {
    chart: {
      renderTo: 'fluid-chart-line-pressure-downstream',
      defaultSeriesType: 'area',
    },
    legend: false,
    text: 'Downstream Line Pressure',
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
  }
  subscribe_to_fluid_pressure()

#-------------------------------------------
# Subscribers
#-------------------------------------------

subscribe_to_temperature = ->
  temperature = new window.ros.Topic {
    name        : window.topics.temperature,
    messageType : "xhab/Temperature"
  }
  temperature.subscribe (response) ->
    temperature_handler(response)

#-------------------------------------------
# Publishers
#-------------------------------------------

init_publish_to_joint_angles = ->
  console.log 'creating topic'
  window.joint_angles_topic = new window.ros.Topic {
    name        : window.topics.control_joint_angles,
    messageType : "xhab/TrajectoryJointAngles"
  }
#-------------------------------------------
# Response callbacks
#-------------------------------------------

temperature_handler = (response) ->
  console.log response
  chart = window.charts.temperature
  series = chart.series[0]
  if series.data.length > 50
    shift = true
  else
    shift = false
  value = response.value
  series.addPoint [response.header.stamp.secs*1000, value], true, shift
  $(".fluid-temperature-value").html(value.toFixed(2))

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


