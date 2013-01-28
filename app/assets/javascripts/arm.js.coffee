jQuery ->
  scale = 16
  R = Raphael("arm-portrait", 400, 400)
  _base = { width: 4*scale, height: 1*scale }
  _base_joint = { width: 2*scale, height: 2.5*scale, joint_offset_y: 0.5*scale, joint_offset_x: 0.5*scale } 
  _link1 = { width: 1.5*scale, height: 6.75*scale }
  _joint1 = { width: 2*scale, height: 2.5*scale, joint_offset_y: 0.5*scale, joint_offset_x: 0.5*scale }
  _link2 = { width: 1.5*scale, height: 4.6*scale }
  _joint2 = { width: 2*scale, height: 2.5*scale, joint_offset_y: 0.5*scale }
  _link3 = { width: 1.5*scale, height: 3.5*scale }
  _joint3 = { width: 1.25*scale, height: 1.5*scale, joint_offset_y: 0.5*scale }
  _joint4 = { width: 1.75*scale, height: 2.5*scale, joint_offset_y: 0.5*scale }
  _hand = { width: 2*scale, height: 1.25*scale }
  _gripper = { width: 0.5*scale, height: 2*scale }

  base = R.rect(10,370,_base.width,_base.height).attr({fill: "yellow"})
  base_joint = R.rect( (base.attrs.x + base.attrs.width/2) - _base_joint.width/2, base.attrs.y - _base_joint.height, _base_joint.width, _base_joint.height).attr({ fill: "black" })
  base_joint_axis = R.ellipse( base_joint.attrs.x + _base_joint.width/2, base_joint.attrs.y + _base_joint.joint_offset_y, 0, 0).attr({ fill: "red" })
  link1 = R.rect( (base_joint.attrs.x + base_joint.attrs.width/2) - _link1.width/2, (base_joint.attrs.y + _base_joint.joint_offset_y*2) - _link1.height, _link1.width, _link1.height).attr({ fill: "yellow" })
  joint1 = R.rect( (link1.attrs.x + _link1.width/2) - _joint1.width/2, link1.attrs.y, _joint1.width, _joint1.height).attr({ fill: "black"})
  joint1_axis = R.ellipse( joint1.attrs.x + _joint1.width/2, joint1.attrs.y + _joint1.joint_offset_y).attr({fill: "red"}) 
  link2 = R.rect( (joint1.attrs.x + _joint1.width/2) - _link2.width/2, joint1.attrs.y - _link2.height + _joint1.joint_offset_y*2, _link2.width, _link2.height).attr({ fill: "yellow" })
  joint2 = R.rect( (link2.attrs.x + _link2.width/2) - _joint2.width/2, link2.attrs.y, _joint2.width, _joint2.height).attr({ fill: "black"})
  joint2_axis = R.ellipse( joint2.attrs.x + _joint2.width/2, joint2.attrs.y + _joint2.joint_offset_y).attr({fill: "red"}) 
  link3 = R.rect( (joint2.attrs.x + _joint2.width/2) - _link3.width/2, joint2.attrs.y - _link3.height + _joint2.joint_offset_y*2, _link3.width, _link3.height).attr({ fill: "yellow" })
  joint3 = R.rect( (link3.attrs.x + _link3.width/2) - _joint3.width/2, link3.attrs.y - _joint3.height, _joint3.width, _joint3.height).attr({ fill: "black"})
  joint4 = R.rect( (joint3.attrs.x + _joint3.width/2) - _joint4.width/2, joint3.attrs.y - _joint4.height, _joint4.width, _joint4.height).attr({ fill: "black"})
  hand = R.rect( (joint4.attrs.x + _joint4.width/2) - _hand.width/2, joint4.attrs.y - _hand.height, _hand.width, _hand.height).attr({ fill: "gray" })
  gripper = R.rect( (hand.attrs.x + _hand.width/2) - _gripper.width/2, hand.attrs.y - _gripper.height, _gripper.width, _gripper.height).attr({ fill: "gray" })
  console.log(base_joint_axis)
 
  shoulder = R.set()
  shoulder.push(link1, joint1, joint1_axis)#, link2, joint2, link3, joint3, joint4)
  
  elbow1 = R.set()
  elbow1.push(link2, joint2)#, link3, joint3, joint4)
  
  elbow2 = R.set()
  elbow2.push(link3, joint3, joint4, hand, gripper)
  
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
     
