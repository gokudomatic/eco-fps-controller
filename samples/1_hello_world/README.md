Demo 1 : Hello World

This demo is the simplest case of use of the eco-fps-controller. It is simply the component added to a scene with a map and collision.
The controller is by default set to no weapon and no sound. Commands are using actions (ui_up,ui_down,ui_left,ui_right,ui_jump by default; they can be changed).
This demo shows the inherent capabilities of the controller to move freely in a 3d world with collisions. Slopes (testcubes with rotation) are there to test the capability of the controller to climb them up and down while sticking to the ground. Also the ground is a plane with 2 collision planes close to each other. This is because of Godot's physic engine limitation, when a moving object with high velocity goes through thin walls. By adding a second wall, or by giving a volume to a wall, this problem can be avoided.

Moving platforms are implemented too. In Godot there's a restriction about how to determine if the floor is moving. Therefore a  ground that is moving needs to be a rigid body with custom integration. And only then it can be animated with an animation player with its linear velocity automatically set up.