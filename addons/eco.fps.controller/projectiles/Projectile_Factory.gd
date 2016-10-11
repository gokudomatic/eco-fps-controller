
extends Node

const basic_projectile=preload("res://addons/eco.fps.controller/projectiles/Basic.tscn")
const basic_laser=preload("res://addons/eco.fps.controller/projectiles/energy_blast.tscn")
const basic_ball=preload("res://addons/eco.fps.controller/projectiles/energy_ball.tscn")
const basic_bomb=preload("res://addons/eco.fps.controller/projectiles/bomb.tscn")
const grenade=preload("res://addons/eco.fps.controller/projectiles/grenade.tscn")
const basic_rocket=preload("res://addons/eco.fps.controller/projectiles/rocket.tscn")
const missile=preload("res://addons/eco.fps.controller/projectiles/missile.tscn")
const needle=preload("res://addons/eco.fps.controller/projectiles/needle.tscn")

const base_empty=preload("res://addons/eco.fps.controller/weapon_base/empty_base.tscn")
const base_projectile=preload("res://addons/eco.fps.controller/weapon_base/projectile_base.tscn")
const base_instant=preload("res://addons/eco.fps.controller/weapon_base/instant_base.tscn")
const base_flamethrower=preload("res://addons/eco.fps.controller/weapon_base/flamethrower_base.tscn")
const base_laser=preload("res://addons/eco.fps.controller/weapon_base/laser_base.tscn")

const laser_class=preload("res://addons/eco.fps.controller/projectiles/laser.tscn")
const bolt_class=preload("res://addons/eco.fps.controller/projectiles/thunderbolt.tscn")

const explosion1=preload("res://addons/eco.fps.controller/explosions/Explosion1.tscn")
const explosion_fire1=preload("res://addons/eco.fps.controller/explosions/Explosion_fire1.tscn")
const explosion_acide1=preload("res://addons/eco.fps.controller/explosions/Explosion_acide.tscn")
const impact_class=preload("res://addons/eco.fps.controller/explosions/impact.tscn")
const bullet_impact_class=preload("res://addons/eco.fps.controller/explosions/bullet_impact.tscn")

var _names={}

func _init():
	register("pistol",1,0,0)
	register("magic wand",1,1,0)
	register("ball",0,0,1)
	register("beam",0,0,0)
	register("grenade",0,1,0)
	register("rocket",0,2,0)
	register("flame",2,0,0)
	register("laser",3,0,0)
	register("bolt",3,1,0)

func _ready():
	pass

func get_base(type):
	if type==0:
		return base_projectile.instance()
	elif type==1:
		return base_instant.instance()
	elif type==2:
		return base_flamethrower.instance()
	elif type==3:
		return base_laser.instance()
	else:
		return base_empty.instance()

func get_projectiles(type,shape,amount=1):
	if type==1:
		return get_bomb(shape,amount)
	elif type==2:
		return get_rocket(shape,amount)
	else:
		return get_basic_projectiles(shape,amount)

func get_basic_projectiles(type,amount=1):
	var result=[]
	var meshes=[]
	
	var clazz=basic_laser
	if type==1:
		clazz=basic_ball

	for i in range(amount):
		var p=basic_projectile.instance()
		
		p.add_mesh(clazz.instance())
		result.append(p)
	
	return result

func get_bomb(type,amount=1):
	var result=[]
	var meshes=[]
	
	var clazz=grenade
	var explosion_clazz=explosion1

	for i in range(amount):
		var p=basic_bomb.instance()
		var g=clazz.instance()
		g.tic_sfx_name="grenade_tic"
		p.add_mesh(g)
		p.add_explosion(explosion_clazz.instance())
		result.append(p)
	
	return result

func get_rocket(type,amount=1):
	var result=[]
	var meshes=[]
	
	var clazz=missile
	var explosion_clazz=explosion1
	
	if type==1:
		clazz=needle

	for i in range(amount):
		var p=basic_rocket.instance()
		p.add_mesh(clazz.instance())
		p.add_explosion(explosion_clazz.instance())
		result.append(p)
	
	return result

func get_impact(type,shape):
	if type==0:
		return bullet_impact_class.instance()
	elif type==1:
		return impact_class.instance()

func get_impact_explosion_class(type):
	if type=="fire":
		return explosion_fire1
	elif type=="acide":
		return explosion_acide1
	elif type=="explosion":
		return explosion1
	else:
		return null

func get_laser_class(type):
	if type==1:
		return bolt_class
	else:
		return laser_class

func get_shoot_sound(base,type,shape):
	var sounds=[]
	
	if base==0:
		if type==1:
			sounds=["projectile_grenade"]
		elif type==2:
			sounds=["projectile_missile"]
		else:
			if shape==1:
				sounds=["projectile_ball"]
			else:
				sounds=["projectile_beam"]
	elif base==1:
		if type==1:
			sounds=["magic_shot"]
		else:
			sounds=["instant_shot"]
	elif base==2:
		sounds=["flamethrower_basic"]
	elif base==3:
		if type==0:
			sounds=["laser_beam"]
		elif type==1:
			sounds=["laser_zap"]
	
	if sounds.size()==0:
		return null
	elif sounds.size()>1:
		var i=randi() % sounds.size()
		return sounds[i]
	else:
		return sounds[0]

func get_impact_sound(base,type,shape,elemental,is_special=true):
	var sounds=[]
	
	if base==0:
		if type==1 or type==2:
			sounds=["explosion_default"]
		else:
			if is_special:
				sounds=get_elemental_impact_sound(elemental)
			else:
				sounds=["impact_default"]
	elif base==1 and is_special:
		sounds=get_elemental_impact_sound(elemental)
	
	if sounds.size()==0:
		return null
	elif sounds.size()>1:
		var i=randi() % sounds.size()
		return sounds[i]
	else:
		return sounds[0]

func get_elemental_impact_sound(elemental):
	if elemental=="explosion":
		return ["elemental_explosion"]
	else:
		return []

func register(name,base_id,weapon_id,bullet_id):
	_names[name]=[base_id,weapon_id,bullet_id]

func get_config(name):
	if name==null || name=="":
		return null
	
	if _names.has(name):
		return _names[name]
	else:
		return null