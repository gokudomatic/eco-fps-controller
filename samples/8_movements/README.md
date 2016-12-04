# Demo 8 : Movements

This demo displays a couple of extra features. In this map you can walk over or under a bridge. By pressing C you toggle the crouching mode. Ctrl will temporarily crouch the controller, as long as the key is pressed.
Shift allows to run faster, even in crouch mode.
A ladder is also featured. It is an Area node with toggles the fly mode of the controller. 

The terrain was created with blender (sculpt mode) to make an irregular shape. The controller doesn't have any problem to walk, as long as the map has a volume (not juste a 2d plane with relief but no width) and the normals of the faces are properly oriented. Wrong normals can cause bugs and let the controller falls through the ground.
