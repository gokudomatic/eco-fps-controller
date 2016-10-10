# eco-fps-controller
The eco-fps-controller is a 3d fps controller for Godot Engine, part of the eco-fps-framework. It implements all the essential functions of a player for a First Person Perspective game and the basic functions of a shooting game.

This component has no dependencies and can be added in any Godot Project via the Assetlib or by copying the addons folder from github in the project directory. Samples are provided to illustrate each part of this component.

The controller is mostly a Kinematicbody node with a camera. It can navigate in most scenes as long as there are other physics bodies, especially a map. It can climb stairs, but it is strongly advised to make staires with hidden slopes for collision. The controller has however no problem with moving platforms, such as lifts.

This controller has only the most basic features but it provides a strong structure for easy and clean extensions, such as new weapons or special features. Its philosophy is to keep all the flexibility provided by Godot to build any kind of feature. It could as well help to build a standard war game as a more platform oriented game with various kind of weapons, like Metroid, or a totally different kind of game like Portal or even a turn-based roguelike like Legend of Grimrock.

The controller provides only basic assets for particle effects and projectiles. No models are provided for weapons and the character himself. No sound samples are provided. It is however easy to bind 3d models and sound samples to the controller.

This component is licensed as MIT and can be freely used and modified for any kind of project, including commercial games. The resources of the samples have however their own license.

