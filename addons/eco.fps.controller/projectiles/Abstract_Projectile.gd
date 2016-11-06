
extends Node

var sfx_class=preload("res://addons/eco.fps.controller/explosions/SpacialSoundEffect.tscn")

var owner=null setget set_owner
var _mesh=null
var explosion_class=null
var sound_name=null
var alive=true
var target=null
var sample_lib=null

var delayed_timer=0.5
var copies=null setget set_copies

func die():
	alive=false
	queue_free()

func _ready():
	if _get_child()!=null:
		_get_child().parent=self
		set_ready()

func _get_child():
	return _mesh

func add_mesh(mesh):
	_mesh=mesh
	add_child(mesh)
	mesh.parent=self
	set_ready()

func set_owner(value):
	owner=value
	delayed_timer=get_modifier("attack.split_delay")

func set_ready():
	pass

func set_copies(value):
	copies=value
	
	if copies!=null:
		set_fixed_process(true)

func get_modifier(key):
	return owner.get_data().get_modifier(key)
	
func _fixed_process(delta):
	if delayed_timer>0:
		delayed_timer-=delta
	else:
		split()

func split():
	
	set_fixed_process(false)
	var t=get_projectile_transform()
	if t==null or not alive:
		return
	
	var is_right=true
	var up=Vector3(0,1,0)
	var delta_angle=0
	for c in copies:
		if is_right:
			delta_angle=-delta_angle+PI/8
		else:
			delta_angle=-delta_angle
		is_right=!is_right
		var t1=t.rotated(up,delta_angle)
		
		c.set_projectile_transform(self,t1)
		
		if not alive:
			break
		
		c.target=target
		get_parent_spatial().add_child(c)

func get_projectile_transform():
	return get_transform()

func set_projectile_transform(src,t):
	set_transform(t)

func reset_target():
	if get_modifier("projectile.homing"):
		target=owner.current_target

func rotate_to_target(direction):
	var target_z=get_global_transform().looking_at(target.get_global_transform().origin+target.aim_offset,Vector3(0,1,0)).orthonormalized().basis.z
	var vx=Vector2(-direction.x,-direction.z).angle_to(Vector2(target_z.x,target_z.z))
	var vy=direction.y-Vector2(1,0).angle_to(Vector2(1,target_z.y))
	return [vx,vy]

func create_impact_sfx():
	if sound_name!=null:
		var sfx=sfx_class.instance()
		sfx.set_sample_library(sample_lib)
		owner.get_parent_spatial().add_child(sfx)
		sfx.set_global_transform(get_global_transform())
		sfx.play_sound(sound_name)

func set_sample_library(value):
	sample_lib=value
	if _mesh!=null and _mesh.has_method("set_sample_library"):
		_mesh.set_sample_library(value)

func set_elemental(value):
	pass