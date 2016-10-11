
extends Area

var parent=null

func _on_bullet_body_enter( body ):
	print(body)
	parent._on_body_enter(body)
	
func rescale(size):
	pass