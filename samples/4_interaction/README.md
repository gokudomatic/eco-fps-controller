Demo 4 : interactions 

This demo shows how the controller can interact with its environment. Technically it can do 2 interactions: use and shoot.
The controller can use an object if it's close enough, looking at it (raycast for interaction is attached to the camera) and the use action key is pressed. The object only need a method called "use" with the controller as parameter.
A projectile (or ray weapon) can interact with an object if this one has the method "hit". It can have 2 parameters : source and special flag.
Source is the projectil/weapon itself, which helps to retrieve special attributes of the controller and to give him points for killing an enemy. Source should have the method get_data() to get the data model of the controller.
Special flag is a boolean which tells if the projectile/weapon has a special effect, like incendiary effect or explosion effect. Those effects can be retrieved in the controller's data and the target object can handle the effect, like for instance start to burn itself.

There is no support of custom interaction with an object, like assigning a second action to the interaction. But a custom "weapon" or a custom extended controller can give the possibility to implement such custom behavior. Those are not implemented in the standard controller because they are very specific to a special kind of gameplay.