extends "res://addons/eco.fps.controller/projectiles/Projectile_Factory.gd"

# custom factory which extends the default one
# mostly, it's just making available the custom bullet, its base and its impact effect.

func _init():
	._init()
	# register the custom weapon's id
	register("bfg",5,10,0)

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

func get_base(type):
	if type==5:
		return preload("custom_base.tscn").instance()
	else:
		return .get_base(type)

func get_impact(type,shape):
	if type==10:
		return preload("beam_impact.tscn").instance()
	else:
		return .get_impact(type,shape)