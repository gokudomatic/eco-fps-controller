
extends Spatial

var bullet_factory=null

var owner=null setget set_owner
var data=null

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

func reload():
	pass

func reset():
	pass

func get_modifier(key):
	return owner.get_data().get_modifier(key)

func set_sample_library(lib):
	pass