extends "res://addons/eco.fps.controller/projectiles/Abstract_Projectile.gd"

var velocity=Vector3() 
var speed=1
var acceleration=1.1
var age=1

func _ready():
	get_node("AnimationPlayer").play("normal")
	set_process(true)

func _process(delta):
	age+=delta
	if age>3:
		die()
	
	var direction=Vector3()-get_global_transform().basis[2]
	
	direction = direction.normalized()
	speed*=acceleration
	velocity=direction*speed
	
	var motion=velocity*delta
	set_translation(get_translation()+motion)


func _on_Area_body_enter( body ):
	if body!=owner:
		if body.has_method("hit"): 
			body.hit(self,false)
		
		get_node("AnimationPlayer").play("explosion")
		acceleration=0
		velocity=0

func die():
	print("die")
	.die()