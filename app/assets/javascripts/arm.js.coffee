shoulder_rotate_angle = 0
elbow1_rotate_angle = 0
elbow2_rotate_angle = 0

@arm_execute_motion = ->
  console.log 'sending angles'
  message = new window.ros.Message {
    shoulder1_angle : shoulder_rotate_angle + 114,
    shoulder2_angle : shoulder_rotate_angle + 112.9,
    elbow1_angle    : elbow1_rotate_angle + 134.6,
    elbow2_angle    : elbow2_rotate_angle + 102.9,
    wrist_angle     : 1,
    step_number     : 1,
  }
  console.log message
  window.joint_angles_topic.publish message

  #window.shoulder.forEach( (el) ->
    #el.animate({ transform: "r" + shoulder_rotate_angle + "," + base_joint_axis.attrs.cx + "," + base_joint_axis.attrs.cy}, 3000)
  #)

  #window.elbow1.forEach( (el) ->
    #el.animate({ transform: "r" + shoulder_rotate_angle + "," + base_joint_axis.attrs.cx + "," + base_joint_axis.attrs.cy + "r" + elbow1_rotate_angle + "," + joint1_axis.attrs.cx + "," + joint1_axis.attrs.cy}, 3000)
  #)

  #window.elbow2.forEach( (el) ->
    #el.animate({ transform: "r" + shoulder_rotate_angle + "," + base_joint_axis.attrs.cx + "," + base_joint_axis.attrs.cy + "r" + elbow1_rotate_angle + "," + joint1_axis.attrs.cx + "," + joint1_axis.attrs.cy + "r" + elbow2_rotate_angle + "," + joint2_axis.attrs.cx + "," + joint2_axis.attrs.cy}, 3000)
  #) 
   
@rotate_shoulder = (el, i) ->
  el.attr({transform: "r" + shoulder_rotate_angle + "," + (window.base_joint.attrs.x + window._base_joint.joint_offset_x) + "," + (window.base_joint.attrs.y + window._base_joint.joint_offset_y)})

@rotate_plan_joint = (joint,angle) ->
  if joint == 0
    shoulder_rotate_angle = angle
  else if joint == 1
    elbow1_rotate_angle = angle
  else if joint == 2
    elbow2_rotate_angle = angle

  window.plan_shoulder.forEach( (el) ->
    el.attr({ transform: "r" + shoulder_rotate_angle + "," + window.plan_base_joint_axis.attrs.cx + "," + window.plan_base_joint_axis.attrs.cy})
  )

  window.plan_elbow1.forEach( (el) ->
    el.attr({ transform: "r" + shoulder_rotate_angle + "," + window.plan_base_joint_axis.attrs.cx + "," + window.plan_base_joint_axis.attrs.cy + "r" + elbow1_rotate_angle + "," + window.plan_joint1_axis.attrs.cx + "," + window.plan_joint1_axis.attrs.cy})
  )

  window.plan_elbow2.forEach( (el) ->
    el.attr({ transform: "r" + shoulder_rotate_angle + "," + window.plan_base_joint_axis.attrs.cx + "," + window.plan_base_joint_axis.attrs.cy + "r" + elbow1_rotate_angle + "," + window.plan_joint1_axis.attrs.cx + "," + window.plan_joint1_axis.attrs.cy + "r" + elbow2_rotate_angle + "," + window.plan_joint2_axis.attrs.cx + "," + window.plan_joint2_axis.attrs.cy})
  )

  arm_execute_motion()
  
$ -> 
  $("#arm-execute-motion").click ->
    arm_execute_motion()

$ ->
  console.log 'arm'
  scale = 21
  w = window
  R = Raphael("arm-portrait", 500, 500)
  w._base = { width: 4*scale, height: 1*scale }
  w._base_joint = { width: 2*scale, height: 2.5*scale, joint_offset_y: 0.5*scale, joint_offset_x: 0.5*scale } 
  w._link1 = { width: 1.5*scale, height: 6.75*scale }
  w._joint1 = { width: 2*scale, height: 2.5*scale, joint_offset_y: 0.5*scale, joint_offset_x: 0.5*scale }
  w._link2 = { width: 1.5*scale, height: 4.6*scale }
  w._joint2 = { width: 2*scale, height: 2.5*scale, joint_offset_y: 0.5*scale }
  w._link3 = { width: 1.5*scale, height: 3.5*scale }
  w._joint3 = { width: 1.25*scale, height: 1.5*scale, joint_offset_y: 0.5*scale }
  w._joint4 = { width: 1.75*scale, height: 2.5*scale, joint_offset_y: 0.5*scale }
  w._hand = { width: 2*scale, height: 1.25*scale }
  w._gripper = { width: 0.5*scale, height: 2*scale }

  w.base = R.rect(10,470,w._base.width,w._base.height).attr({fill: "yellow"})
  w.base_joint = R.rect( (w.base.attrs.x + w.base.attrs.width/2) - w._base_joint.width/2, w.base.attrs.y - w._base_joint.height, w._base_joint.width, w._base_joint.height).attr({ fill: "black" })
  w.base_joint_axis = R.ellipse( w.base_joint.attrs.x + w._base_joint.width/2, w.base_joint.attrs.y + w._base_joint.joint_offset_y, 0, 0).attr({ fill: "red" })
  w.link1 = R.rect( (w.base_joint.attrs.x + w.base_joint.attrs.width/2) - w._link1.width/2, (w.base_joint.attrs.y + w._base_joint.joint_offset_y*2) - w._link1.height, w._link1.width, w._link1.height).attr({ fill: "yellow" })
  w.joint1 = R.rect( (w.link1.attrs.x + w._link1.width/2) - w._joint1.width/2, w.link1.attrs.y, w._joint1.width, w._joint1.height).attr({ fill: "black"})
  w.joint1_axis = R.ellipse( w.joint1.attrs.x + w._joint1.width/2, w.joint1.attrs.y + w._joint1.joint_offset_y).attr({fill: "red"}) 
  w.link2 = R.rect( (w.joint1.attrs.x + w._joint1.width/2) - w._link2.width/2, w.joint1.attrs.y - w._link2.height + w._joint1.joint_offset_y*2, w._link2.width, w._link2.height).attr({ fill: "yellow" })
  w.joint2 = R.rect( (w.link2.attrs.x + w._link2.width/2) - w._joint2.width/2, w.link2.attrs.y, w._joint2.width, w._joint2.height).attr({ fill: "black"})
  w.joint2_axis = R.ellipse( w.joint2.attrs.x + w._joint2.width/2, w.joint2.attrs.y + w._joint2.joint_offset_y).attr({fill: "red"}) 
  w.link3 = R.rect( (w.joint2.attrs.x + w._joint2.width/2) - w._link3.width/2, w.joint2.attrs.y - w._link3.height + w._joint2.joint_offset_y*2, w._link3.width, w._link3.height).attr({ fill: "yellow" })
  w.joint3 = R.rect( (w.link3.attrs.x + w._link3.width/2) - w._joint3.width/2, w.link3.attrs.y - w._joint3.height, w._joint3.width, w._joint3.height).attr({ fill: "black"})
  w.joint4 = R.rect( (w.joint3.attrs.x + w._joint3.width/2) - w._joint4.width/2, w.joint3.attrs.y - w._joint4.height, w._joint4.width, w._joint4.height).attr({ fill: "black"})
  w.hand = R.rect( (w.joint4.attrs.x + w._joint4.width/2) - w._hand.width/2, w.joint4.attrs.y - w._hand.height, w._hand.width, w._hand.height).attr({ fill: "gray" })
  w.gripper = R.rect( (w.hand.attrs.x + w._hand.width/2) - w._gripper.width/2, w.hand.attrs.y - w._gripper.height, w._gripper.width, w._gripper.height).attr({ fill: "gray" })
 
  # clone the arm for pose planning
  w.plan_base_joint_axis = R.ellipse( w.base_joint.attrs.x + w._base_joint.width/2, w.base_joint.attrs.y + w._base_joint.joint_offset_y, 4, 4).attr({ fill: "red" })
  w.plan_link1 = w.link1.clone().attr({fill: "white", opacity: 0.5}).data("group", "shoulder")
  w.plan_joint1 = w.joint1.clone().attr({fill: "white", opacity: 0.5}).data("group", "shoulder")
  w.plan_joint1_axis = R.ellipse( w.joint1.attrs.x + w._joint1.width/2, w.joint1.attrs.y + w._joint1.joint_offset_y, 4, 4).attr({fill: "red"}) 
  w.plan_link2 = w.link2.clone().attr({fill: "white", opacity: 0.5}).data("group", "elbow1")
  w.plan_joint2 = w.joint2.clone().attr({fill: "white", opacity: 0.5}).data("group", "elbow1")
  w.plan_joint2_axis = R.ellipse( w.joint2.attrs.x + w._joint2.width/2, w.joint2.attrs.y + w._joint2.joint_offset_y, 4, 4).attr({fill: "red"}) 
  w.plan_link3 = w.link3.clone().attr({fill: "white", opacity: 0.5}).data("group", "elbow2")
  w.plan_joint3 = w.joint3.clone().attr({fill: "white", opacity: 0.5}).data("group", "elbow2")
  w.plan_joint4 = w.joint4.clone().attr({fill: "white", opacity: 0.5}).data("group", "elbow2")
  w.plan_hand = w.hand.clone().attr({fill: "white", opacity: 0.5}).data("group", "elbow2")
  w.plan_gripper = w.gripper.clone().attr({fill: "white", opacity: 0.5}).data("group", "elbow2")
 
  w.shoulder = R.set()
  w.shoulder.push(w.link1, w.joint1, w.joint1_axis)#, w.link2, w.joint2, w.link3, w.joint3, w.joint4)
  w.plan_shoulder = R.set()
  w.plan_shoulder.push(w.plan_link1, w.plan_joint1, w.plan_joint1_axis)#, w.plan_link2, w.plan_joint2, w.plan_link3, w.plan_joint3, w.plan_joint4)

  w.elbow1 = R.set()
  w.elbow1.push(w.link2, w.joint2)#, w.link3, w.joint3, w.joint4)
  w.plan_elbow1 = R.set()
  w.plan_elbow1.push(w.plan_link2, w.plan_joint2, w.plan_joint2_axis)
  
  w.elbow2 = R.set()
  w.elbow2.push(w.link3, w.joint3, w.joint4, w.hand, w.gripper)
  w.plan_elbow2 = R.set()
  w.plan_elbow2.push(w.plan_link3, w.plan_joint3, w.plan_joint4, w.plan_hand, w.plan_gripper)
  
  rotate_shoulder = ->
    shoulder.transform("r10," + (base_joint.attrs.x + _base_joint.joint_offset_x) + "," + (base_joint.attrs.y + _base_joint.joint_offset_y))
  
  rotate = (el) ->
    el.animate({ transform: "r10," + (base_joint.attrs.x + _base_joint.joint_offset_x) + "," + (base_joint.attrs.y + _base_joint.joint_offset_y)}, 3000)

  @default_pose = ->
    shoulder.forEach( (el) ->
      el.animate({ transform: "r0," + base_joint_axis.attrs.cx + "," + base_joint_axis.attrs.cy}, 3000)
    )

    elbow1.forEach( (el) ->
      el.animate({ transform: "r0," + base_joint_axis.attrs.cx + "," + base_joint_axis.attrs.cy + "r0," + joint1_axis.attrs.cx + "," + joint1_axis.attrs.cy}, 3000)
    )

    elbow2.forEach( (el) ->
      el.animate({ transform: "r0," + base_joint_axis.attrs.cx + "," + base_joint_axis.attrs.cy + "r0," + joint1_axis.attrs.cx + "," + joint1_axis.attrs.cy + "r0," + joint2_axis.attrs.cx + "," + joint2_axis.attrs.cy}, 3000)
    ) 
  
  @pose1 = ->
    shoulder.forEach( (el) ->
      el.animate({ transform: "r50," + base_joint_axis.attrs.cx + "," + base_joint_axis.attrs.cy}, 3000)
    )

    elbow1.forEach( (el) ->
      el.animate({ transform: "r50," + base_joint_axis.attrs.cx + "," + base_joint_axis.attrs.cy + "r70," + joint1_axis.attrs.cx + "," + joint1_axis.attrs.cy}, 3000)
    )

    elbow2.forEach( (el) ->
      el.animate({ transform: "r50," + base_joint_axis.attrs.cx + "," + base_joint_axis.attrs.cy + "r70," + joint1_axis.attrs.cx + "," + joint1_axis.attrs.cy + "r-40," + joint2_axis.attrs.cx + "," + joint2_axis.attrs.cy}, 3000)
    )

  @pose2 = ->
    shoulder.forEach( (el) ->
      el.animate({ transform: "r30," + base_joint_axis.attrs.cx + "," + base_joint_axis.attrs.cy}, 3000)
    )

    elbow1.forEach( (el) ->
      el.animate({ transform: "r30," + base_joint_axis.attrs.cx + "," + base_joint_axis.attrs.cy + "r60," + joint1_axis.attrs.cx + "," + joint1_axis.attrs.cy}, 3000)
    )

    elbow2.forEach( (el) ->
      el.animate({ transform: "r30," + base_joint_axis.attrs.cx + "," + base_joint_axis.attrs.cy + "r60," + joint1_axis.attrs.cx + "," + joint1_axis.attrs.cy + "r90," + joint2_axis.attrs.cx + "," + joint2_axis.attrs.cy}, 3000)
    )
    
  @pose3 = ->
    shoulder.forEach( (el) ->
      el.animate({ transform: "r90," + base_joint_axis.attrs.cx + "," + base_joint_axis.attrs.cy}, 3000)
    )

    elbow1.forEach( (el) ->
      el.animate({ transform: "r90," + base_joint_axis.attrs.cx + "," + base_joint_axis.attrs.cy + "r-90," + joint1_axis.attrs.cx + "," + joint1_axis.attrs.cy}, 3000)
    )

    elbow2.forEach( (el) ->
      el.animate({ transform: "r90," + base_joint_axis.attrs.cx + "," + base_joint_axis.attrs.cy + "r-90," + joint1_axis.attrs.cx + "," + joint1_axis.attrs.cy + "r90," + joint2_axis.attrs.cx + "," + joint2_axis.attrs.cy}, 3000)
    )

  @pose4 = ->
    shoulder.forEach( (el) ->
      el.animate({ transform: "r15," + base_joint_axis.attrs.cx + "," + base_joint_axis.attrs.cy}, 3000)
    )

    elbow1.forEach( (el) ->
      el.animate({ transform: "r15," + base_joint_axis.attrs.cx + "," + base_joint_axis.attrs.cy + "r110," + joint1_axis.attrs.cx + "," + joint1_axis.attrs.cy}, 3000)
    )

    elbow2.forEach( (el) ->
      el.animate({ transform: "r15," + base_joint_axis.attrs.cx + "," + base_joint_axis.attrs.cy + "r110," + joint1_axis.attrs.cx + "," + joint1_axis.attrs.cy + "r-110," + joint2_axis.attrs.cx + "," + joint2_axis.attrs.cy}, 3000)
    )

  @lie_down = ->
    shoulder.stop()
    elbow1.stop()
    elbow2.stop()
    shoulder.forEach( (el) ->
      el.animate({ transform: "r90," + base_joint_axis.attrs.cx + "," + base_joint_axis.attrs.cy}, 300)
    )

    elbow1.forEach( (el) ->
      el.animate({ transform: "r90," + base_joint_axis.attrs.cx + "," + base_joint_axis.attrs.cy + "r0," + joint1_axis.attrs.cx + "," + joint1_axis.attrs.cy}, 300)
    )

    elbow2.forEach( (el) ->
      el.animate({ transform: "r90," + base_joint_axis.attrs.cx + "," + base_joint_axis.attrs.cy + "r0," + joint1_axis.attrs.cx + "," + joint1_axis.attrs.cy + "r0," + joint2_axis.attrs.cx + "," + joint2_axis.attrs.cy}, 300)
    )
     
