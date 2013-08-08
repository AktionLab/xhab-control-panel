#-------------------------------------------
# Globals
#-------------------------------------------

# Rosbridge 
window.ros_master_ip = "10.1.57.143"
window.connection = null
window.rosbridge_host = "ws://#{window.ros_master_ip}:9090"

# pump state globals
window.pump   = 0
window.valve1 = 0
window.valve2 = 0

# end effector direction


# ROS topics for pub/sub
window.topics = {
  data_temperature:        "/data/fluid/temperature",
  control_joint_angles:    "/control/arm/joint_angles",
  control_end_effector:    "/control/arm/end_effector",
  data_arm_end_effector_status: "/data/arm/end_effector_status",
  data_joint_angles:       "/data/arm/joint_angles",
  control_leds:            "/control/led",
  control_dc_motor:        "/control/dc_motor",
  control_linear_actuator: "/control/linear_act",
  control_linear_actuator_water: "/control/linear_act_water",
  control_pump_state:      "/control/pump_state",
  control_stepper_motor:   "/control/stepper_motor",
  data_sensors:            "/data/sensors",
  data_ph:                 "/data/ph_sensor",
  data_ec:                 "/data/ec_sensor",
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
  init_publish_to_control_leds()
  init_publish_to_control_dc_motor()
  init_publish_to_control_stepper_motor()
  init_publish_to_control_pump_state()
  init_publish_to_control_linear_actuator()
  init_publish_to_control_linear_actuator_water()
  init_publish_to_joint_angles()
  init_publish_to_end_effector()
  init_publish_to_end_effector_status()
  init_subscribe_to_sensor_data()

init_jwplayer = ->
  jwplayer("main-camera").setup
    file: "http://localhost:8090/test.flv"
    controlbar: 'none'
    dock: false
    icons: 'false'
    autostart: true
    width: '100%'
    "controlbar.idlehide": true

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
  $("[data-ui-context=test]").click()
    

#-------------------------------------------
# Utility functions
#-------------------------------------------

log = (message) -> 
  if console != undefined
    console.log message

#-------------------------------------------
# Linear Actuator Water UP
#-------------------------------------------
$ ->
  $("#linear_actuator_water_up").click ->
    message = new window.ros.Message {
      pin_one      : true,
      pin_two      : false,
      mode         : 2000,
    }
    log window.control_linear_actuator_water_topic 
    window.control_linear_actuator_water_topic.publish message
    console.log message

#-------------------------------------------
# Linear Actuator Water DOWN
#-------------------------------------------
$ ->
  $("#linear_actuator_water_down").click ->
    message = new window.ros.Message {
      pin_one   : false,
      pin_two   : true,
      mode      : 2000,
    }
    log window.control_linear_actuator_water_topic 
    window.control_linear_actuator_water_topic.publish message
    console.log message


#-------------------------------------------
# Linear Actuator UP
#-------------------------------------------
$ ->
  $("#linear_actuator_up").click ->
    message = new window.ros.Message {
      direction : 0,
      mode      : 3000,  
    }
    log window.control_linear_actuator_topic 
    window.control_linear_actuator_topic.publish message
    console.log message

#-------------------------------------------
# Linear Actuator DOWN
#-------------------------------------------
$ ->
  $("#linear_actuator_down").click ->
    message = new window.ros.Message {
      direction : 1,
      mode      : 3000,  
    }
    log window.control_linear_actuator_topic 
    window.control_linear_actuator_topic.publish message
    console.log message

#-------------------------------------------
# DC Motor
#-------------------------------------------
$ ->
  $("#rotate_plant").click ->
    rotate_amount = $("input#rotate_plant_amount").val()
    log rotate_amount
    dir = 0
    if rotate_amount > 0
      dir = 1
    message = new window.ros.Message {
      direction : dir,
      mode      : parseFloat(Math.abs(rotate_amount)),  
    }
    log window.control_dc_motor_topic 
    window.control_dc_motor_topic.publish message
    console.log message

#-------------------------------------------
# Stepper Motor
#-------------------------------------------
$ ->
  $("#rotate_table").click ->
    scalar = 2/1.8*8
    steps = parseInt(parseInt($("input#rotate_table_amount").val())*scalar)
    dir = 0
    if steps > 0
      dir = 1
    message = new window.ros.Message {
      direction     : dir,
      enable_hold   : false,
      steps_desired : Math.abs(steps),  
    }
    log window.control_stepper_motor_topic
    window.control_stepper_motor_topic.publish message
    console.log message

#-------------------------------------------
# Pump ON
#-------------------------------------------
$ ->
  $("#pump_on").click ->
    message = new window.ros.Message {
      pump_mode    : 1,
      valve_1_mode : window.valve1, 
      valve_2_mode : window.valve2,
    }
    log window.control_pump_state_topic
    window.control_pump_state_topic.publish message
    window.pump = 1
    log message

#-------------------------------------------
# Pump OFF
#-------------------------------------------
$ ->
  $("#pump_off").click ->
    message = new window.ros.Message {
      pump_mode    : 0,
      valve_1_mode : window.valve1, 
      valve_2_mode : window.valve2,
    }
    log window.control_pump_state_topic
    window.control_pump_state_topic.publish message
    window.pump = 0
    log message
    
#-------------------------------------------
# Valve 1 OPEN
#-------------------------------------------
$ ->
  $("#upstream_valve_open").click ->
    message = new window.ros.Message {
      pump_mode    : window.pump,
      valve_1_mode : 1, 
      valve_2_mode : window.valve2,
    }
    log window.control_pump_state_topic
    window.control_pump_state_topic.publish message
    window.valve1 = 1
    log message

#-------------------------------------------
# Valve 1 CLOSE
#-------------------------------------------
$ ->
  $("#upstream_valve_close").click ->
    message = new window.ros.Message {
      pump_mode    : window.pump,
      valve_1_mode : 0, 
      valve_2_mode : window.valve2,
    }
    log window.control_pump_state_topic
    window.control_pump_state_topic.publish message
    window.valve1 = 0
    log message

#-------------------------------------------
# Valve 2 OPEN
#-------------------------------------------
$ ->
  $("#downstream_valve_open").click ->
    message = new window.ros.Message {
      pump_mode    : window.pump,
      valve_1_mode : window.valve1, 
      valve_2_mode : 1,
    }
    log window.control_pump_state_topic
    window.control_pump_state_topic.publish message
    window.valve2 = 1
    log message

#-------------------------------------------
# Valve 2 CLOSE
#-------------------------------------------
$ ->
  $("#downstream_valve_close").click ->
    message = new window.ros.Message {
      pump_mode    : window.pump,
      valve_1_mode : window.valve1, 
      valve_2_mode : 0,
    }
    log window.control_pump_state_topic
    window.control_pump_state_topic.publish message
    window.valve2 = 0
    log message

#-------------------------------------------
# End Effector OPEN
#-------------------------------------------
$ ->
  $("#arm-open-gripper").click ->
    message = new window.ros.Message {
      data    : 2,
    }
    log window.end_effector_topic
    window.end_effector_topic.publish message
    log message

#-------------------------------------------
# End Effector STOP
#-------------------------------------------
$ ->
  $("#arm-stop-gripper").click ->
    message = new window.ros.Message {
      data    : 0,
    }
    log window.end_effector_topic
    window.end_effector_topic.publish message
    log message

#-------------------------------------------
# End Effector CLOSE
#-------------------------------------------
$ ->
  $("#arm-close-gripper").click ->
    message = new window.ros.Message {
      data    : 1,
    }
    log window.end_effector_topic
    window.end_effector_topic.publish message
    log message


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

  $(".slider#joint-slider3").slider {
    value: 0,
    orientation: "vertical",
    range: "min",
    min: -180,
    max: 180,
    step: 1,
    slide: (event, ui) ->
      joint_index = $(event.target).data("joint")
      $("span#joint#{joint_index}-value").html(ui.value)
      window.wrist_rotate_angle = ui.value  
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
      if led_level > 0 && window.lights_glow[led_index] != undefined
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
      
      message = new window.ros.Message {
        id    : $(event.target).data('led-index'),
        value : ui.value
      }
      log window.control_leds_topic
      window.control_leds_topic.publish message
      console.log message
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
    name        : window.topics.data_temperature,
    messageType : "xhab/Temperature"
  }
  temperature.subscribe (response) ->
    temperature_handler(response)

subscribe_to_joint_angles = ->
  joint_angles = new window.ros.Topic {
    name        : window.topics.data_joint_angles,
    messageType : "xhab/JointAngles"
  }
  joint_angles.subscribe (response) ->
    joint_angles_handler(response)

init_subscribe_to_sensor_data = ->
  sensor_data = new window.ros.Topic {
    name        : window.topics.data_sensors,
    messageType : "xhab/SensorData"
  }
  log sensor_data
  sensor_data.subscribe (response) ->
    log 'received'
    sensor_data_handler(response)

subscribe_to_ph_sensor = ->
  ph_sensor_data = new window.ros.Topic {
    name        : window.topics.data_ph,
    messageType : "std_msgs/Float32"
  }
  ph_sensor_data.subscribe (response) ->
    ph_sensor_data_handler(response)

subscribe_to_pec_sensor = ->
  ec_sensor_data = new window.ros.Topic {
    name        : window.topics.data_ec,
    messageType : "std_msgs/Float32"
  }
  ec_sensor_data.subscribe (response) ->
    ec_sensor_data_handler(response)

#-------------------------------------------
# Publishers
#-------------------------------------------

init_publish_to_joint_angles = ->
  console.log 'creating topic'
  window.joint_angles_topic = new window.ros.Topic {
    name        : window.topics.control_joint_angles,
    messageType : "xhab/TrajectoryJointAngles"
  }

init_publish_to_end_effector = ->
  console.log 'creating topic'
  window.end_effector_topic = new window.ros.Topic {
    name        : window.topics.control_end_effector,
    messageType : "std_msgs/Int32"
  }

init_publish_to_end_effector_status = ->
  console.log 'creating topic'
  window.data_arm_end_effector_status_topic = new window.ros.Topic {
    name        : window.topics.data_arm_end_effector_status,
    messageType : "std_msgs/Int32"
  }

init_publish_to_control_leds = ->
  console.log 'init led publisher'
  window.control_leds_topic = new window.ros.Topic {
    name        : window.topics.control_leds,
    messageType : "xhab/LEDState",
  }

init_publish_to_control_dc_motor = ->
  console.log 'init dc motor'
  window.control_dc_motor_topic = new window.ros.Topic {
    name        : window.topics.control_dc_motor,
    messageType : "xhab/DcMotor",
  }

init_publish_to_control_pump_state = ->
  console.log 'init pump and valves'
  window.control_pump_state_topic = new window.ros.Topic {
    name        : window.topics.control_pump_state,
    messageType : "xhab/PumpState",
  }

init_publish_to_control_stepper_motor = ->
  console.log 'init stepper motor'
  window.control_stepper_motor_topic = new window.ros.Topic {
    name        : window.topics.control_stepper_motor,
    messageType : "xhab/Stepper_Motor",
  }

init_publish_to_control_linear_actuator = ->
  console.log 'init linear actuator'
  window.control_linear_actuator_topic = new window.ros.Topic {
    name        : window.topics.control_linear_actuator,
    messageType : "xhab/DcMotor",
  }

init_publish_to_control_linear_actuator_water = ->
  console.log 'init linear actuator water'
  window.control_linear_actuator_water_topic = new window.ros.Topic {
    name        : window.topics.control_linear_actuator_water,
    messageType : "xhab/LinWater",
  }

#-------------------------------------------
# Response callbacks
#-------------------------------------------
sensor_data_handler = (response) ->
  log response
  $("#temp").html(response.temp_data.value)
  $("#upstream-pressure").html(response.pressure_data.side_pressure)
  $("#downstream-pressure").html(response.pressure_data.back_pressure)
  $("#moisture-level").html(response.moisture_data)
  $("#fluid-level-top").html(response.fluid_lvl_data.top_lvl)
  $("#fluid-level-mid").html(response.fluid_lvl_data.mid_lvl)
  $("#fluid-level-bot").html(response.fluid_lvl_data.bot_lvl)

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

joint_angles_handler = (response) ->
  console.log response

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

