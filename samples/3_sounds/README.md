Demo 3 : sounds 

The sounds are handled in this controller with a sample library for all sounds. 
There are 4 kinds of sounds :
- those made by the controller
- those made by the weapon
- those made by the projectile
- those made by the impact of the projectile

If for the controller and the weapon itself the sounds could be global, the sounds made by the projectile and the impact must be spatial. But in any case all sounds are spatial sounds. And each part (controller, weapon base, projectile, impact) must have a spatial sample player with an empty sample library. It is then possible to set the attribute sample player of the controller to the path of an existing sample player to share its sample library to all spatial sample players of the controller.

Names of the samples are predefined. It is required to set the right sample name to assign a sample to a sound effect.

