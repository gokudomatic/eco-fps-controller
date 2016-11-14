extends "res://addons/eco.fps.controller/projectiles/Abstract_Projectile.gd"

# custom bullet, which acts like a standard slow beam but which hits all enemies in the camera view when it collides with something. See bfg9000 from doom.

onready var sfx=get_node("sfx") # sound effect node
var speed=1 # current speed of the node
var acceleration=1.1 # constant acceleration of the node
var age=3 # time remaining before the bullet dies (mostly for when it goes out of the map)
var factory=null # bullet factory
var charging=true # current state of the bullet. If it's charging, it doesn't move. When it's done charging, the bullet starts to move.

func _ready():
	set_process(true)

func _process(delta):
	if charging:
		return # bullet is charging. don't do anything
	
	# bullet is not charging and therefore is moving
	

	
	# check if bullet's lifespan ended
	age-=delta
	if age<=0:
		die()
	
	# the speed is constantly accelerating
	speed*=acceleration
	# moves the bullet straight forward
	var direction=Vector3()-get_global_transform().basis[2]
	direction = direction.normalized()
	set_translation(get_translation()+direction*speed*delta)

func _on_Area_body_enter( body ):
	if charging:
		return # if it's charging, dont bother with collisions
	
		# if it wasn't visible, show the beam
	if !get_node("Particles").is_emitting():
		get_node("AnimationPlayer").play("normal")
	
	# trigger the custom explosion when hitting something
	if body!=owner:
		get_node("AnimationPlayer").play("explosion")
		acceleration=0
		
		camera_impact()

func set_sample_library(lib):
	# when using sound effects, the common sample library is given here
	get_node("sfx").set_sample_library(lib)

func camera_impact():
	# the bfg9000 has a special impact effect. It hits all enemies that are in the field of the player's camera.
	# Therefore all nodes in group "enemy" shall be tested to see if it's in the camera field. If so, hit it.
	
	var data=owner.get_data()
	
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy.has_method("get_screen_visibility") and enemy.get_screen_visibility():
			if enemy.has_method("hit"): 
				# hit the enemy
				enemy.hit(self,false)
				
				# create an impact node and display it at the enemy's coordinate.
				var t=Transform()
				t.origin=enemy.get_global_transform().origin
				if enemy.has_method("get_aim_offset"):
					var enemy_aim_offset=enemy.get_aim_offset()
					t.origin+=enemy_aim_offset
				
				var instance=factory.get_impact(data.bullet_type,data.bullet_shape)  
				owner.get_parent_spatial().add_child(instance)
				instance.set_global_transform(t)
