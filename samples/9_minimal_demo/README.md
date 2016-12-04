# Demo 9 : minimal controller

It is possible to use a lightweight version of the controller, without any dependency for weapons nor special features. It does only walk, run, crouch and climb ladders(fly).

To use this version, create a KinematicBody and assign the light_fps_controller.gd script to it. And that's all. The script will generate all the internal nodes at the initialization time.
Since it doesn't have any dependencies, the file light_fps_controller.gd can be used alone and anywhere.
