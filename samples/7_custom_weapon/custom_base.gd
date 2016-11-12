extends "res://addons/eco.fps.controller/weapon_base/projectile_abstract.gd"

onready var sfx=get_node("sfx")

var charge_delay=1

var charge=0

var bullet=null

func _fixed_process(delta):
	if charge<=charge_delay:
		charge+=delta
		data.notify_attribute_change("custom_charge",charge)
	

func set_sample_library(lib):
	sfx.set_sample_library(lib)

func shoot():
	if bullet!=null:
		return false
	
	set_fixed_process(true)
	charge=0
	data.notify_attribute_change("custom_charge",charge)
	
	bullet=bullet_factory.get_projectiles(data.bullet_type,data.bullet_shape,1)[0]
	bullet.owner=owner
	bullet.factory=bullet_factory
	bullet.set_sample_library(sfx.get_sample_library())
	
	add_child(bullet)
	
	return true

func stop_shoot():
	set_fixed_process(false)
	
	if charge>=charge_delay:
		data.notify_ammo_used()
		var transform=bullet.get_global_transform()
		remove_child(bullet)
		owner.get_parent_spatial().add_child(bullet)
		bullet.set_global_transform(transform)
		bullet.charging=false # launching bullet
		
	else:
		bullet.die()
	
	bullet=null
	charge=0
	data.notify_attribute_change("custom_charge",charge)


func reset():
	.reset()
	charge=0
