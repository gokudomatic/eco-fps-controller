
extends Node

var bullet_factory=null

var life=3 setget set_life
var shield=100
var has_shield=false
var shield_damage_factor=1
var shield_regen_speed=50
var no_shield_timeout=0
var no_shield_max_timeout=5
var walk_speed=15 setget set_speed
var jump_strength=9
var hit_invincibility_timeout=0
var hit_invincibility_max_timeout=1
var fire_rate=3
var reload_time=2
var sound_to_play=null

signal attribute_changed(key,value)
signal pool_changed(pool_type)
signal ammo_used

var modifiers= {
	"bomb.sticky":false,
	"bomb.resist_explosion":true,
	"attack.size":3,
	"attack.split_factor":0,
	"attack.split_delay":0.1,
	"attack.elemental_impact":"",
	"attack.elemental_chance":8,
	"attack.elemental_power":0.5,
	"explosion.power":40,
	"projectile.homing":false,
	"attack.autoaim":false,
	"multijump":0
}

var bullet_type=0 setget set_bullet_type
var bullet_shape=0 setget set_bullet_shape
var weapon_base_type=0 setget set_weapon_base_type

var bullet_pool_capacity=-1
var bullet_max_capacity=-1

var attack_regen_speed=1
var attack_frequency=0.1
var attack_capacity=1
var attack_damage_factor=1

func _ready():
	notify_attribute_change("shield",shield)
	notify_attribute_change("life",life)

func _fixed_process(delta):
	
	if hit_invincibility_timeout>0:
		hit_invincibility_timeout-=delta
	
	var old_shield=shield
	if no_shield_timeout>0:
		no_shield_timeout-=delta
	else:
		if shield<100:
			shield+=delta*shield_regen_speed
	
	if old_shield!=shield:
		notify_attribute_change("shield",shield)

func hit(damage):
	
	if has_shield and shield>0:
		shield-=damage*shield_damage_factor
	else:
		if hit_invincibility_timeout<=0:
			hit_invincibility_timeout=hit_invincibility_max_timeout
			life-=1
	
	if has_shield:
		no_shield_timeout=no_shield_max_timeout
	
	if has_shield and shield<=0:
		shield=0
	
	if life<1:
		life=0
		# dying scream
		
	else:
		# scream pain
		sound_to_play="hurt01"

	notify_attribute_change("shield",shield)
	notify_attribute_change("life",life)

func set_life(value):
	life=value
	if life<1:
		life=0
	
	notify_attribute_change("life",life)

func set_speed(value):
	walk_speed=min(value,100)

func get_item(item_node):
	item_node.execute()

func set_bullet_shape(value):
	bullet_shape=value
	emit_signal("pool_changed","bullet")

func set_bullet_type(value):
	bullet_type=value
	emit_signal("pool_changed","bullet")

func set_weapon_base_type(value):
	weapon_base_type=value
	emit_signal("pool_changed","base")

func get_modifier(key):
	if modifiers.has(key):
		return modifiers[key]
	else:
		return null

func set_modifier(key,value):
	modifiers[key]=value

func reset_pool():
	emit_signal("pool_changed","bullet")

func equip_weapon(config):
	if config!=null:
		set_weapon_base_type(config[0])
		set_bullet_type(config[1])
		set_bullet_shape(config[2])
	else:
		set_weapon_base_type(-1)
		set_bullet_type(-1)
		set_bullet_shape(-1)

func notify_attribute_change(key,value):
	emit_signal("attribute_changed",key,value)

func notify_ammo_used():
	emit_signal("ammo_used")