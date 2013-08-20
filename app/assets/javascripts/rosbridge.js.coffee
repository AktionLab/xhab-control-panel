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
  data_state:              "/data/arduino_states",
  data_callback:           "/data/callback",
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
  init_fluid_ph_chart()
  init_fluid_temperature_chart()
  init_fluid_tds_chart()
  init_moisture_chart()
  #init_arm_camera()
  init_publish_to_control_leds()
  init_publish_to_control_dc_motor()
  init_publish_to_control_stepper_motor()
  init_publish_to_control_pump_state()
  init_publish_to_control_linear_actuator()
  init_publish_to_control_linear_actuator_water()
  init_publish_to_joint_angles()
  #init_publish_to_end_effector()
  #init_subscribe_to_sensor_data()
  init_subscribe_to_state()
  init_subscribe_to_callback()

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
  init_view_switching()

init_view_switching = ->
  $(".main-nav li a").on 'click', (e) ->
    context = $(e.currentTarget).data('ui-context')
    $(".ui-context").hide()
    $(".ui-context.ui-" + context).show(0,redraw_charts)
    return false
  $(".ui-context.ui-dashboard").show()
  #$("[data-ui-context=dashboard]").click()
    

#-------------------------------------------
# Utility functions
#-------------------------------------------

log = (message) -> 
  if console != undefined
    console.log message

@disable_buttons = (buttons) ->
  $.each buttons, (i,v) ->
    $("##{v}").attr('disabled','disabled')

@enable_buttons = (buttons) ->
  $.each buttons, (i,v) ->
    $("##{v}").removeAttr('disabled')

@highlight_buttons = (buttons) ->
  $.each buttons, (i,v) ->
    $("##{v}").addClass('btn-green')

@unhighlight_buttons = (buttons) ->
  $.each buttons, (i,v) ->
    $("##{v}").removeClass('btn-green')
 
#-------------------------------------------
# Linear Actuator Water UP
#-------------------------------------------
$ ->
  $("#dripper-extend").click ->
    message = new window.ros.Message {
      pin_one      : true,
      pin_two      : false,
      mode         : 2300,
    }
    log window.control_linear_actuator_water_topic 
    window.control_linear_actuator_water_topic.publish message
    console.log message

#-------------------------------------------
# Linear Actuator Water DOWN
#-------------------------------------------
$ ->
  $("#dripper-retract").click ->
    message = new window.ros.Message {
      pin_one   : false,
      pin_two   : true,
      mode      : 2300,
    }
    log window.control_linear_actuator_water_topic 
    window.control_linear_actuator_water_topic.publish message
    console.log message


#-------------------------------------------
# Linear Actuator UP
#-------------------------------------------
$ ->
  $("#probe-remove").click ->
    if $(this).attr('disabled') == 'disabled'
      return
    message = new window.ros.Message {
      direction : 0,
      mode      : 3500,  
    }
    log window.control_linear_actuator_topic 
    window.control_linear_actuator_topic.publish message
    console.log message
    $(this).attr('disabled','disabled')

#-------------------------------------------
# Linear Actuator DOWN
#-------------------------------------------
$ ->
  $("#probe-insert").click ->
    if $(this).attr('disabled') == 'disabled'
      return
    message = new window.ros.Message {
      direction : 1,
      mode      : 3500,  
    }
    log window.control_linear_actuator_topic 
    window.control_linear_actuator_topic.publish message
    console.log message
    $(this).attr('disabled','disabled')

#-------------------------------------------
# DC Motor
#-------------------------------------------
$ ->
  $("#rotate_plant").click ->
    rotate_amount = $("input[name=rotate-table-user-amount]").val()
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

  $("#rotate-plant-cw").click ->
    rotate_amount = 0.7
    dir = 1
    message = new window.ros.Message {
      direction : dir,
      mode      : parseFloat(Math.abs(rotate_amount)),  
    }
    log window.control_dc_motor_topic
    window.control_dc_motor_topic.publish message
    console.log message

  $("#rotate-plant-ccw").click ->
    rotate_amount = 0.7
    dir = 0
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
  $("#rotate-table").click ->
    scalar = 2/1.75*8
    steps = parseInt(parseInt($("input[name=rotate-table-user-amount]").val())*scalar)
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

  $("#rotate-table-cw").click ->
    scalar = 2/1.8*8
    steps = 40
    dir = 1
    message = new window.ros.Message {
      direction     : dir,
      enable_hold   : false,
      steps_desired : Math.abs(steps),  
    }
    log window.control_stepper_motor_topic
    window.control_stepper_motor_topic.publish message
    console.log message

  $("#rotate-table-ccw").click ->
    scalar = 2/1.8*8
    steps = 40
    dir = 0
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
  $("#pump-on").click ->
    message = new window.ros.Message {
      pump_mode    : 1,
      valve_1_mode : window.valve1, 
      valve_2_mode : window.valve2,
    }
    log window.control_pump_state_topic
    window.control_pump_state_topic.publish message
    window.pump = 1
    highlight_buttons([$(this).id])
    $(this).removeClass('btn-primary')
    log message

#-------------------------------------------
# Pump OFF
#-------------------------------------------
$ ->
  $("#pump-off").click ->
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
  $("#upstream-valve-open").click ->
    message = new window.ros.Message {
      pump_mode    : window.pump,
      valve_1_mode : 1, 
      valve_2_mode : window.valve2,
    }
    log window.control_pump_state_topic
    window.control_pump_state_topic.publish message
    window.valve1 = 1
    highlight_buttons([$(this).attr('id')])
    $(this).removeClass('btn-primary')
    log message

#-------------------------------------------
# Valve 1 CLOSE
#-------------------------------------------
$ ->
  $("#upstream-valve-close").click ->
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
  $("#downstream-valve-open").click ->
    message = new window.ros.Message {
      pump_mode    : window.pump,
      valve_1_mode : window.valve1, 
      valve_2_mode : 1,
    }
    log window.control_pump_state_topic
    window.control_pump_state_topic.publish message
    window.valve2 = 1
    disable_buttons([$(this).id])
    highlight_buttons([$(this).id])
    $(this).removeClass('btn-primary')
    log message

#-------------------------------------------
# Valve 2 CLOSE
#-------------------------------------------
$ ->
  $("#downstream-valve-close").click ->
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
      else if ui.value == 2
        value = "1/3 power"
      else if ui.value == 3
        value = "2/3 power"
      else if ui.value == 1
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
  
  window.sensor_gui = Raphael("soil-sensor-arm", 100, 150)

  window.sensor_gui.setStart()

  probe = window.sensor_gui.rect(0,5,60,5)
  probe.attr "fill", "#4444ff"
 
  arm = window.sensor_gui.rect(10,0,10,90)
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
  light_paper_width = 360
  light_paper_height = 360
  center_x_pos = light_paper_width/2
  center_y_pos = light_paper_width/2
  led_radius = 86
  pot_radius = 40
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
    x_pos = Math.cos(angle)*0.4*(light_paper_width - 2*pot_radius) + 0.5*light_paper_width
    y_pos = Math.sin(angle)*0.4*(light_paper_height - 2*pot_radius) + 0.5*light_paper_height
    x_pos_label = Math.cos(angle)*0.5*(light_paper_width - 2*pot_radius) + 0.5*light_paper_width
    y_pos_label = Math.sin(angle)*0.5*(light_paper_height - 2*pot_radius) + 0.5*light_paper_height
    rect = window.eps_gui.rect x_pos - led_radius/2 , y_pos - led_radius/2, led_radius, led_radius
    rect.attr("stroke", "#fff")
    rect.attr("fill-opacity", 0.75)
    window.lights.push(rect)
    
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

init_subscribe_to_state = ->
  state_data = new window.ros.Topic {
    name        : window.topics.data_state,
    messageType : "xhab/ArduinoState"
  }
  state_data.subscribe (response) ->
    state_data_handler(response)

init_subscribe_to_callback = ->
  callback_data = new window.ros.Topic {
    name        : window.topics.data_callback,
    messageType : "xhab/CallBack"
  }
  callback_data.subscribe (response) ->
    callback_data_handler(response)

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

state_data_handler = (r) ->
  log r

  if r.PumpState == 1
    highlight_buttons(['pump-on'])
  if r.UpStreamValveState == 1
    highlight_buttons(['upstream-valve-open'])
  if r.LinActState == 1
    enable_buttons(['probe-insert'])
    disable_buttons(['probe-remove'])
  else
    disable_buttons(['probe-insert'])
    enable_buttons(['probe-remove'])

  
callback_data_handler = (r) ->
  log r
  switch r.cid
    when 7,8,9
      if r.mid == 1
        block()
      else
        unblock()
    when 11
      if r.mid == 1
        highlight_buttons(['upstream-valve-open'])  
      else
        enable_buttons(['upstream-valve-open'])
        unhighlight_buttons(['upstream-valve-open'])
        $('#upstream-valve-open').addClass('btn-primary')
    when 12
      if r.mid == 1
        highlight_buttons(['pump-on'])
      else
        enable_buttons(['pump-on'])
        unhighlight_buttons(['pump-on'])
        $('#pump-on').addClass('btn-primary')
 
block = ->
  $("div#whiteout").show()

unblock = ->
  $("div#whiteout").hide()
