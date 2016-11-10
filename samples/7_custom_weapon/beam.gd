extends "res://addons/eco.fps.controller/projectiles/Abstract_Projectile.gd"

onready var sfx=get_node("sfx")

var velocity=Vector3() 
var speed=1
var acceleration=1.1
var age=3

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
		if body.has_method("hit"): 
			body.hit(self,false)
		
		get_node("AnimationPlayer").play("explosion")
		acceleration=0
		velocity=0

func set_sample_library(lib):
	get_node("sfx").set_sample_library(lib)