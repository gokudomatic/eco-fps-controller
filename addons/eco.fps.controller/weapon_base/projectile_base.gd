
extends "abstract_base.gd"

var bullet_pool=[]

onready var sfx=get_node("sfx")

func set_sample_library(lib):
	sfx.set_sample_library(lib)

func shoot():
	if cartridge_capacity>0 and remaining_bullets<=0:
		return false
	
	if bullet_pool.size()>0:
		var bullet=bullet_pool[0]
		bullet_pool.pop_front()
		var transform=get_global_transform()
		if data.get_modifier("attack.autoaim") and owner.current_target!=null:
			transform=transform.looking_at(owner.current_target.get_global_transform().origin,Vector3(0,1,0))
		bullet.set_transform(transform.orthonormalized())
		bullet.reset_target()
		owner.get_parent_spatial().add_child(bullet)
		
		sfx.play(bullet_factory.get_shoot_sound(0,data.bullet_type,data.bullet_shape))
		
		if cartridge_capacity>0:
			remaining_bullets-=1
			data.notify_attribute_change("nb_bullets",remaining_bullets)
			data.notify_ammo_used()
		
		return true
	else:
		return false

func regenerate():
	if bullet_pool.size()<60:
		
		var elemental=data.get_modifier("attack.elemental_impact")
		var is_special=elemental!=null and elemental!=""
		
		var bullets=bullet_factory.get_projectiles(data.bullet_type,data.bullet_shape,5)
		var impact_class=bullet_factory.get_impact_explosion_class(elemental)
		
		for b in bullets:
			b.owner=owner
			b.set_sample_library(sfx.get_sample_library())
			if is_special and randi()%get_modifier("attack.elemental_chance") == 0:
				b.explosion_class=impact_class
				b.sound_name=bullet_factory.get_impact_sound(0,data.bullet_type,data.bullet_shape,elemental,true)
			else:
				b.explosion_class=null
				b.sound_name=bullet_factory.get_impact_sound(0,data.bullet_type,data.bullet_shape,elemental,false)
			bullet_pool.append(b)
			var split_factor=data.get_modifier("attack.split_factor")
			if split_factor>0:
				var sub_bullets=bullet_factory.get_projectiles(data.bullet_type,data.bullet_shape,split_factor)
				for sb in sub_bullets:
					sb.owner=owner
					sb.set_sample_library(sfx.get_sample_library())
					if is_special and randi()%get_modifier("attack.elemental_chance") == 0:
						sb.explosion_class=impact_class
						sb.sound_name=bullet_factory.get_impact_sound(0,data.bullet_type,data.bullet_shape,elemental,true)
					else:
						sb.explosion_class=null
						sb.sound_name=bullet_factory.get_impact_sound(0,data.bullet_type,data.bullet_shape,elemental,false)
				b.copies=sub_bullets

func reset():
	.reset()
	for b in bullet_pool:
		b.queue_free()
	bullet_pool.clear()
