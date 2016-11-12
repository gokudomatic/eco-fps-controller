
extends "abstract_base.gd"

onready var sfx=get_node("sfx")

var power=0
var velocity=Vector3()

var ammo_consummation_timeout=0

func set_owner(value):
	.set_owner(value)

func shoot():
	if cartridge_capacity>0 and remaining_bullets<=0:
		return false
	
	if not get_node("flame").is_emitting():
		get_node("flame").set_emitting(true)
		set_fixed_process(true)
		sfx.play(bullet_factory.get_shoot_sound(2,data.bullet_type,data.bullet_shape))
	
	return true

func stop_shoot():
	get_node("flame").set_emitting(false)
	set_fixed_process(false)
	sfx.stop_all()

func _fixed_process(delta):
	ammo_consummation_timeout-=delta
	if cartridge_capacity>-1 and ammo_consummation_timeout<=0:
		remaining_bullets-=1
		data.notify_attribute_change("nb_bullets",remaining_bullets)
		data.notify_ammo_used()
		ammo_consummation_timeout=data.fire_rate
		
		if remaining_bullets<=0:
			stop_shoot()
	
	for body in get_node("Area").get_overlapping_bodies():
		if body!=owner and body.has_method("hit"): 
			body.hit(self,true)

func reset():
	.reset()
	var mod=data.get_modifier("attack.elemental_impact")
	if mod=="explosion":
		data.set_modifier("attack.elemental_impact","fire")
		mod="fire"
	
	var flame=get_node("flame")
	if mod=="fire":
		flame.set_color_phase_color(0,Color(1,0.913725,0,0.890196))
		flame.set_color_phase_color(1,Color(1,0.090196,0,0.796078))
		flame.set_color_phase_color(2,Color(0.019608,0,0,0))
	elif mod=="acide":
		flame.set_color_phase_color(0,Color(0.069158,0.429688,0.038605,0.891317))
		flame.set_color_phase_color(1,Color(0.018265,0.222656,0.031039,0.79717))
		flame.set_color_phase_color(2,Color(0.019608,0,0,0))

func set_sample_library(lib):
	sfx.set_sample_library(lib)
