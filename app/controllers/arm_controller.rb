class ArmController < ApplicationController
  respond_to :json

  def coords_to_joint_angles
    ik = IKSolver.new
    angles = ik.findJointAngles(params[:x].to_f, params[:y].to_f, params[:phi].to_f, [0,0,0])
    respond_with angles
    #angles = [params[:x],data.y,data.phi]
    #respond_with angles   
  end
end
