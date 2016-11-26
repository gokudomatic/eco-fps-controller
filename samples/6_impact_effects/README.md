Demo 6 : Impact effects

A weapon can have various impact effects, like incendiary effect, corrosion or explosion. This demo show the already integrated effects and how to implement them on the enemies.
To activate an effect, the data model of the player must have its attribute "attack.elemental_impact" set to the effect name. Any other name would give no effect. The already integrated effects (fire, acide, explosion) have each of them an impact scene which is inserted at the impact point of the projectile (or the weapon if it's an instant impact weapon). The scene dies by itself when it finished to play its animation.

In this demo there's a dummy which the player can practice to shoot. It contains in hits "hit" method the code that handle the special flag and activates an animation depending on which impact effect was activated in the controller's data model. The dummy has a particle node for fire effect and one for acide effect. The name of the effect is the key that each hitten object should gather and handle. But freedom is given to not handle some effects or to handle custom effects. Indeed, if an object doesn't need to care about being set on fire can simply have no code about the name "fire". And on the other hand, if the gameplay requires a custom effect, it is simply done by :
1) set the name of the new effect in the controller's data model
2) implement the scene for the impact effect for this name, and register it in the factory. (*)
3) implement the code for the new effect in each object that must handle this effect.

(*) In the already integrated weapons, the impact scene is taken from the weapon factory, which allows to implement easily more impact effects without modifying the weapon base or projectile. It is also set in a memory queue to avoid a slowdown at the moment of impact.
But if a custom weapon is implemented in a way that doesn't use the factory to create an impact effect, the weapon base (or projectile) must handle itself the selection of the impact scene depending on its name.

There are other attributes in the controller's data model that have influence of the impact effects. The attribute "attack.elemental_chance" tells the probability that an effect happens, in the case it is not wished that an effect happens all the time. The probability is calculated like 1/x chances that happens, where x is the value of the "attack.elemental_chance" attribute. Therefore, to make it happen every time, the value must be set to 1 (and not 0, since that would cause a division by 0 error). A large number would make the probability very low (the value 20 would make it already so rare that it would almost never happen in a game).
If you wish to create a custome parameter for your custom effect, you simply have to add an attribute in the controller's data model like this:
   controller_name.get_data.set_modifier("my_key","my_value")
And to read the attribute, the getter method is get_modifier("my_key").
Those attributes are stored in a dictionnary, unlike the standard fields of the data model. The idea behind is to let the developer be free to extend its attributes without having to extend the data model.