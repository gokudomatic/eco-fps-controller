
extends Spatial

var bullet_factory=null

var owner=null setget set_owner
var data=null

var remaining_bullets=0
var cartridge_capacity=-1
var remaining_total_bullets=0
var max_total_bullets=-1

func set_owner(value):
	owner=value
	data=owner.get_data()
	bullet_factory=owner.bullet_factory

func shoot():
	return false

func stop_shoot():
	pass

func regenerate():
	pass

func reload(amount=-1):
	if amount==-1:
		if max_total_bullets==-1: # unlimited ammo
			amount=cartridge_capacity-remaining_bullets
		else:
			amount=min(cartridge_capacity-remaining_bullets,remaining_total_bullets)
			remaining_total_bullets-=amount
	remaining_bullets+=amount
	data.notify_attribute_change("nb_bullets",remaining_bullets)

func reset():
	cartridge_capacity=data.bullet_pool_capacity
	max_total_bullets=data.bullet_max_capacity
	data.notify_attribute_change("nb_bullets",remaining_bullets)

func get_modifier(key):
	return owner.get_data().get_modifier(key)

func set_sample_library(lib):
	pass