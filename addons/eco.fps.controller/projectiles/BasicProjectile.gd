
extends "Abstract_Projectile.gd"

var velocity=Vector3() setget _set_velocity
var speed=40
var power=20
var age=1

func set_ready():
	set_process(true)
	
func _process(delta):
	age+=delta
	if age>20:
		die()
	
	var aim = get_global_transform().basis
	var direction=Vector3()
	direction-=aim[2]
	
	if target!=null:
		var r=rotate_to_target(direction)
		rotate_x(r[1]*delta*8*age)
		rotate_y(-r[0]*delta*8*age)
	
	
	direction = direction.normalized()
	velocity=direction*speed
	
	var motion=velocity*delta
	set_translation(get_translation()+motion)

func _set_velocity(value):
	velocity=value
	_get_child().velocity=value
	
func _on_body_enter(body):
	if body!=owner and not (body in get_tree().get_nodes_in_group("npc-wall")):
		var special=false
		if explosion_class != null:
			special=true
		if body.has_method("hit"): 
			body.hit(self,special)
			
		var t=Transform()
		t.origin=get_global_transform().origin
			
		if special :
			var explosion=explosion_class.instance()
			explosion.owner=owner
			explosion.set_global_transform(t)
			explosion.rescale(0.2*get_modifier("attack.size"))
			owner.get_parent_spatial().add_child(explosion)
		
		if sound_name!=null:
			var sfx=sfx_class.instance()
			owner.get_parent_spatial().add_child(sfx)
			sfx.set_global_transform(t)
			sfx.set_sample_library(sample_lib)
			sfx.play_sound(sound_name)
		queue_free()

func set_owner(value):
	.set_owner(value)
	var size=get_modifier("attack.size")
	_mesh.rescale(size)