
extends "projectile_abstract.gd"

onready var sfx=get_node("sfx")

const laser_class=preload("res://addons/eco.fps.controller/projectiles/laser.tscn")
const bolt_class=preload("res://addons/eco.fps.controller/projectiles/thunderbolt.tscn")
const SPLIT_STEP=PI/64

onready var direction=get_node("direction")
var main_ray=null
var rays=[]

var ray_class=laser_class
var looking_away=false
var power=1
var velocity=Vector3()

func set_owner(value):
	.set_owner(value)

func shoot():
	var special=false
	
	if data.bullet_type==0:
		if !main_ray.is_enabled():
			sfx.play(bullet_factory.get_shoot_sound(3,data.bullet_type,data.bullet_shape))
	elif data.bullet_type==1:
		if not sfx.is_voice_active(0):
			sfx.play(bullet_factory.get_shoot_sound(3,data.bullet_type,data.bullet_shape))
	_shoot_ray(main_ray,special)
	for r in rays:
		_shoot_ray(r,special)
	
	return true

func _shoot_ray(r,special):
	r.activate(true)
	
	if r.is_colliding():
		var object=r.get_collider()
		var p=r.get_collision_point()
		if object.has_method("hit"):
			object.hit(self,special)

func stop_shoot():
	sfx.stop_all()
	main_ray.activate(false)
	for r in rays:
		r.activate(false)

func reset():
	if data.get_modifier("attack.elemental_impact")=="explosion":
		data.set_modifier("attack.elemental_impact","fire")

	ray_class=bullet_factory.get_laser_class(data.bullet_type)
	
	if main_ray!=null:
		main_ray.queue_free()
	
	main_ray=ray_class.instance()
	main_ray.owner=owner
	main_ray.add_exception_rid(owner)
	direction.add_child(main_ray)
	
	var i=rays.size()

	var is_right=true
	var delta_angle=-i/2*SPLIT_STEP

	var split_factor=data.get_modifier("attack.split_factor")
	if main_ray.has_method("set_split_factor"):
		if i>0:
			for r in rays:
				r.queue_free()
		main_ray.set_split_factor(split_factor)
	else:
		while i<split_factor:
			if is_right:
				delta_angle=-delta_angle+SPLIT_STEP
			else:
				delta_angle=-delta_angle
			is_right=!is_right
			
			var r=ray_class.instance()
			r.owner=owner
			rays.append(r)
			r.add_exception_rid(owner)
			direction.add_child(r)
			r.rotate_y(delta_angle)
			r.set_translation(Vector3(delta_angle,0,0))
			i+=1

	if data.get_modifier("attack.autoaim") or data.get_modifier("projectile.homing"):
		set_process(true)
	else:
		set_process(false)
		direction.set_transform(Transform())

func _process(delta):
	if owner.current_target!=null:
		var t=direction.get_global_transform()
		direction.set_global_transform(t.looking_at(owner.current_target.get_global_transform().origin+owner.current_target.aim_offset,Vector3(0,1,0)))
		looking_away=true
	elif looking_away:
		direction.set_transform(Transform())
		looking_away=false