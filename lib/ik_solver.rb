class IKSolver
# findJointAngles.rb
=begin

 Test for finding the inverse kinematics for the XHAB robotic arm

 Takes in x,y positions in the base reference frame and angle phi in

 degrees as the angle from the base frame's x axis

 Outputs the three joint angles needed for the arm to move

=end
  attr_accessor :coords, :angles
  
  def initialize
    @current_angles = []
  end

  def findJointAngles(x,y,phi,currentAngles)
    vars = {}

    vars[:l1] = 0.1727 #link one length meters
    vars[:l2] = 0.1150 #link two length meters
    vars[:l3] = 0.2235 #link three length meters
    
    scale = 0.0014319
    
    x = x*scale
    y = y*scale

    puts x
    puts y
    
    vars[:alpha] = x - vars[:l3]*Math.cos(phi*Math::PI/180)
    vars[:beta]  = y - vars[:l3]*Math.sin(phi*Math::PI/180)
    vars[:r]     = Math.sqrt(vars[:alpha]**2 + vars[:beta]**2)

    vars[:jointAngles] = Array.new(3)

    vars[:c2] = (vars[:alpha]**2 + vars[:beta]**2 - vars[:l1]**2 - vars[:l2]**2)/(2*vars[:l1]*vars[:l2])
    vars[:s2p] = Math.sqrt(1 - vars[:c2])
    vars[:s2m] = -vars[:s2p]

    vars[:theta2p] = Math.atan2(vars[:s2p]*Math::PI/180,vars[:c2]*Math::PI/180)*180/Math::PI
    vars[:theta2m] = Math.atan2(vars[:s2m]*Math::PI/180,vars[:c2]*Math::PI/180)*180/Math::PI

    if((vars[:theta2p]-currentAngles[1])**2 <= (vars[:theta2m]-currentAngles[1])**2)
      vars[:jointAngles][1] = vars[:theta2p]
    else
      vars[:jointAngles][1] = vars[:theta2m]
    end

    vars[:gamma] = Math.atan2(-vars[:beta]/vars[:r]*Math::PI/180,-vars[:alpha]/vars[:r]*Math::PI/180)*180/Math::PI

    vars[:theta1p] = vars[:gamma] + Math.acos(-(vars[:alpha]**2+vars[:beta]**2+vars[:l1]**2-vars[:l2]**2)/(2*vars[:l1]*vars[:r]))*180/Math::PI
    vars[:theta1m] = vars[:gamma] - Math.acos(-(vars[:alpha]**2+vars[:beta]**2+vars[:l1]**2-vars[:l2]**2)/(2*vars[:l1]*vars[:r]))*180/Math::PI

    if((vars[:theta1p]-currentAngles[0])**2 <= (vars[:theta1m]-currentAngles[0])**2)
      vars[:jointAngles][0] = vars[:theta1p]
    else
      vars[:jointAngles][0] = vars[:theta1m]
    end

    vars[:jointAngles][2] = phi - vars[:jointAngles][0] - vars[:jointAngles][1]

    vars[:jointAngles]
    puts vars.inspect
    vars[:jointAngles]
  end
end
