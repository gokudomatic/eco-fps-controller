extends "res://addons/eco.fps.controller/projectiles/Projectile_Factory.gd"

func _init():
	._init()
	register("bfg",0,10,0)

func get_projectiles(type,shape,amount=1):
	if type==10:
		return get_bfg(shape,amount)
	else:
		return get_basic_projectiles(shape,amount)

func get_bfg(type,amount=1):
	var result=[]
	var clazz=preload("beam.tscn")
	
	for i in range(amount):
		var p=clazz.instance()
		result.append(p)
	
	return result