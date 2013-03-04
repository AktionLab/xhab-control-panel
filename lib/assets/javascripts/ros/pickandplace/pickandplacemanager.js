/*********************************************************************
 *
 * Software License Agreement (BSD License)
 *
 *  Copyright (c) 2010, Robert Bosch LLC.
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above
 *     copyright notice, this list of conditions and the following
 *     disclaimer in the documentation and/or other materials provided
 *     with the distribution.
 *   * Neither the name of the Robert Bosch nor the names of its
 *     contributors may be used to endorse or promote products derived
 *     from this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 *  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 *  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 *  COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 *  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 *  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 *  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 *  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 *  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 *  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 *  POSSIBILITY OF SUCH DAMAGE.
 *
 *********************************************************************/

ros.pickandplace.PickAndPlaceManager = Class.extend({
  init: function(node, vm) 
  {
    this.node = node;
    this.vm = vm;
    this.detectObjectsService = node.serviceClient("/pick_and_place_detect_object");
    this.pointHeadService = node.serviceClient("/pick_and_place_point_head");
    this.detectTableService = node.serviceClient("/pick_and_place_detect_table");
    this.pickObjectService = node.serviceClient("/pick_and_place_pickup_object");
    this.placeObjectService = node.serviceClient("/pick_and_place_place_object");
    this.detachObjectService = node.serviceClient("/pick_and_place_detach_object");
    this.moveArmService = node.serviceClient("/pick_and_place_move_arm_to_side");
    this.moveArmFrontService = node.serviceClient("/pick_and_place_move_arm_to_front");
    
    // a list of detected objects with corresponding visualization model
    this.detectedObjects = [];
    this.detectedObjectNodeIDs = [];
    this.detectedObjectNodes = [];
    this.selectedObjectID = -1;
    
    // set a callback for object selection
    var that = this;
    this.vm.scene_viewer.setOnPick(function(pickInfo) 
    {
      if(pickInfo.valid) {
        
        ros_debug("picked an object");
        // overwrite bounding box settings
	
        pickInfo.closestNode.model.bounding_box.model.setColor([0.8,0.0,0.0]);
        pickInfo.closestNode.model.bounding_box.model.enableLight(true);
        pickInfo.closestNode.model.bounding_box.model.setPrimitives("triangles");
        //pickInfo.closestNode.setEnable(false);
        
        // check which object was selected
        for (var i in that.detectedObjectNodes) {
          var node = that.detectedObjectNodes[i];
          if(node == pickInfo.closestNode) {
            that.selectedObjectID = i;
          }
        }
      }
    });
    
  },
    
  detectObjects: function(command, callback) 
  {
//    var command = "d";
    this.detectObjectsService.call(ros.json([command]), callback);
  },
  
  pointHead: function(side) 
  {
    this.pointHeadService.call(ros.json([side]), function(e){ros_debug("pointHead sucessfull!");});
  },
  
  detectTable: function(callback) 
  {
      
      this.detectTableService.call(ros.json([]), function(e){
	      ros_debug("before callback");   
	  callback(e);
	  ros_debug("detectTable sucessfull!");
      });
  },
  
    moveArm: function(side, callback){
    this.moveArmService.call(ros.json([side]), function(e){
	callback(e);
	ros_debug("moveArm successful!");});
  },
    
  moveArmFront: function(side, callback){
    this.moveArmFrontService.call(ros.json([side]), function(e){
	callback(e);
	ros_debug("moveArmFront successful!");});
  },


    pickObject: function(side, object_id, callback) 
  {
      this.pickObjectService.call(ros.json([side, object_id]), function(e){
	  callback(e);
	  ros_debug("pickObject sucessfull!");});
  },
  
    pickObjectFromSelection: function(side, callback) 
    {
	console.log(this.selectedObjectID);
	if(this.selectedObjectID<0) 
	    return;
	var object = this.detectedObjects[this.selectedObjectID];
	var objectid = object.objectid
	this.pickObjectService.call(ros.json([side, objectid]), function(e){
	    callback(e);
	    ros_debug("pickObject sucessfull!");});
  },
  
    placeObject: function(side, callback) 
  {
    var command = "wo";
//    var arg = "l";
      this.placeObjectService.call(ros.json([command, side]), function(e){
	  callback(e);
	  ros_debug("place successfull!");
      });//ros.nop
  },
  
    detachObject: function(side, callback) 
  {
    this.detachObjectService.call(ros.json([side]), function(e){
	callback(e);
	ros_debug("detachObject sucessfull!");});
  },
  
  addReceivedObject: function(object) 
  {
    // create visualization node
//    var cluster = object.object.cluster;
//    var pointcloud = new ros.pcl.PointCloud();
//    pointcloud.updateFromMessage(cluster);
//    var point_cloud_model = new ros.webgl.PointCloudModel(this.vm.gl, this.vm.shader_manager, pointcloud);
//    point_cloud_model.setPickable(true);
//    var nodeid = this.vm.scene_viewer.addNode(point_cloud_model);
    
   // color table
    var colorable = new Array(
      [128,51,128],
      [51,128,128],
      [255,51,51],
      [51,255,51],
      [51,51,255],
      [51,179,204],
      [128,255,51],
      [255,128,51],
      [51,128,255],
      [239,230,0],
      [230,0,230],
      [0,230,230],
      [230,0,0]
    );

    var pose = new ros.tf.PoseStamped();
    pose.updateFromMessage(object.pose);
    var boundingbox = object.boundingbox;
    var minExtent = [-boundingbox[0]/2.0, -boundingbox[1]/2.0, -boundingbox[2]/2.0];
    var maxExtent = [ boundingbox[0]/2.0,  boundingbox[1]/2.0,  boundingbox[2]/2.0];
   

    var scene_node = new ros.visualization.SceneNode(this);
    var box_model = new ros.visualization.BoxModel(this.vm.gl, this.vm.shader_manager, minExtent, maxExtent);

    scene_node.setModel(box_model);
    scene_node.setFrame(pose.frame_id);
    scene_node.setPickable(true);
    scene_node.matrix = pose.getMatrix();

    box_model.setColor([0.6, 0.6, 0.6]);

    var node_id = this.vm.scene_viewer.addNode(scene_node);



    //var box_model = new ros.visualization.BoxModel(this.vm.gl, this.vm.shader_manager, minExtent, maxExtent);
    //box_model.setFrame(pose.frame_id);
    //box_model.setColor([0.6, 0.6, 0.6]);
    //box_model.setMatrix(pose.getMatrix());
    //box_model.setPickable(true);
    
    //var nodeid = this.vm.scene_viewer.addNode(box_model);
    
    // add object to detected list
    this.detectedObjects.push(object);
    this.detectedObjectNodeIDs.push(node_id);
    this.detectedObjectNodes.push(scene_node);
  },
  
  clearReceivedObjects: function() 
  {
    for (var i in this.detectedObjectNodeIDs) {
      var nodeid = this.detectedObjectNodeIDs[i];
      this.vm.scene_viewer.removeNode(nodeid);
    }
    this.detectedObjects = [];
    this.detectedObjectNodeIDs = [];
    this.detectedObjectNodes = [];
    this.selectedObjectID = -1;
  },
  
  
});

ros.pickandplace.PickAndPlaceManager.HeadDirection = {"LEFT" : "d", 
                                                      "RIGHT" : "d"};
