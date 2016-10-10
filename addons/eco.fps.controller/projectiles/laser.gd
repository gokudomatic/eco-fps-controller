
extends RayCast

var velocity=Vector3()
var power=10
var owner=null

onready var impact=get_node("impact")


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func activate(value):
	set_enabled(value)
	set_process(value)
	#geom.set_hidden(not value)
	get_node("cube").set_hidden(not value)
	impact.set_emitting(value)

func _process(delta):
	var special=false
	if get_modifier("attack.elemental_impact") and randi()%(get_modifier("attack.elemental_chance")*10) ==0:
		special=true
	
	if is_colliding():
		var p=get_global_transform().xform_inv(get_collision_point())
		
		var object=get_collider()
		if object.has_method("hit"):
			velocity=get_collision_point()-get_global_transform().origin
			object.hit(self,special)
		
		impact.set_translation(p)
		if not impact.is_emitting():
			impact.set_emitting(true)
	else:
		if impact.is_emitting():
			impact.set_emitting(false)

func get_modifier(key):
	return owner.get_data().get_modifier(key)