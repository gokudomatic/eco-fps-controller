
extends "Abstract_Projectile.gd"

var explosion=null

func set_ready():
	var aim = get_global_transform().basis
	var direction=Vector3()
	direction-=aim[2]
	direction = direction.normalized()
	
	_mesh.set_linear_velocity(direction*20)

func set_owner(value):
	.set_owner(value)
	var size=get_modifier("attack.size")
	_mesh.rescale(size)

func explode():
	if explosion != null:
		explosion.owner=owner
		explosion.source=self
		var t=Transform()
		t.origin=_mesh.get_transform().origin
		var s=get_modifier("attack.size")
		explosion.set_transform(t)
		explosion.rescale(s)
		_mesh.get_parent_spatial().add_child(explosion)
		
		create_impact_sfx()

	_mesh.queue_free()
	set_fixed_process(false)

func add_explosion(e):
	explosion=e

func get_projectile_transform():
	return _mesh.get_global_transform()

func set_projectile_transform(src,t):
	set_global_transform(t)

func set_elemental(value):
	if explosion.has_method("set_elemental"):
		explosion.set_elemental(value)