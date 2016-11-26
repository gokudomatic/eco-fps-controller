Demo 2 : Basic weapon

This demo features a basic mesh map with collision and a weapon. The weapon is a standard gun and it is configured to shoot a couple of times before it needs to be reloaded by the player. On top of that a weapon mesh is attached to the controller and it is animated when the controller reloads.

The controller contains a couple of weapons ready to use (but no mesh) which can be select by setting the "weapon" attribute. This attribute is a free text which selects a weapon if it contains a valid weapon id. For instance "pistol" select a simple gun which shots only one gun at a time. Other possibilities are "ball","beam","grenade","laser", etc. Those a covered in another demo.
Custom weapons can be added too. To select it, it is only needed to register its id and set the id in the weapon attribute.

About reloading, this is a parameter to set. By default the weapon has unlimited ammo and unlimited cartridge (no need to reload). The demo here is configured to have unlimited ammo but a cartridge of 8 bullets. It means the player can reload as many times he want but he must reload every 8 shots.

The weapon mesh attached to the controller is in the editor a direct child of the controller. But in the runtime it is moved to an internal child of the controller. this is required because the controller itself doesn't rotate and only the "yaw" child rotates when the player moves the mouse. Therefore the weapon mesh needs to be attached to the "yaw" in order to rotate with the camfurther dem era.
An animation player can be used to easily animate the mesh, but it could part of the weapon mesh too (as a scene). The controller send signals related to the weapon, like reload and shoot. It is also possible to not attach a weapon mesh to the controller and display it instead in the 2d view (like in old pseudo 3d games doom & Duke Nukem 3d).

The HUD displays the number of bullets in the cartridge. This label is also updated through a signal from the controller. This signal is a generic signal that is called every time a value of the controller's data is modified. A further explains that in more detail.
