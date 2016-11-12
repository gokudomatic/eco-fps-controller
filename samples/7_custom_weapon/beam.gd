extends "res://addons/eco.fps.controller/projectiles/Abstract_Projectile.gd"

onready var sfx=get_node("sfx")

var velocity=Vector3() 
var speed=1
var acceleration=1.1
var age=3
var factory=null

var charging=true

func _ready():
	set_process(true)

func _process(delta):
	if charging:
		return
	
	age-=delta
	if age<=0:
		die()
	
	var direction=Vector3()-get_global_transform().basis[2]
	
	direction = direction.normalized()
	speed*=acceleration
	velocity=direction*speed
	
	var motion=velocity*delta
	set_translation(get_translation()+motion)

func _on_Area_body_enter( body ):
	if charging:
		return
	
	if !get_node("Particles").is_emitting():
		get_node("AnimationPlayer").play("normal")
	
	if body!=owner:
		get_node("AnimationPlayer").play("explosion")
		acceleration=0
		velocity=0
		
		camera_impact()

func set_sample_library(lib):
	get_node("sfx").set_sample_library(lib)

func camera_impact():
	var data=owner.get_data()
	
	var enemies=get_tree().get_nodes_in_group("enemy")
	var i=0
	for enemy in enemies:
		if enemy.has_method("get_screen_visibility") and enemy.get_screen_visibility():
			if enemy.has_method("hit"): 
				enemy.hit(self,false)
				
				var t=Transform()
				t.origin=enemy.get_global_transform().origin
				if enemy.has_method("get_aim_offset"):
					var enemy_aim_offset=enemy.get_aim_offset()
					t.origin+=enemy_aim_offset
					
				
				var instance=factory.get_impact(data.bullet_type,data.bullet_shape)  
				owner.get_parent_spatial().add_child(instance)
				instance.set_global_transform(t)
#				print("instance=",instance)
