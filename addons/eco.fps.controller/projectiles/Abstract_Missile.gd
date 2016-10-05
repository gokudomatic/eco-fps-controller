
extends Spatial

var parent=null

func _on_area_body_enter( body ):
	parent._on_body_enter(body)
	
func rescale(size):
	pass

func explosion_blown():
	parent.explode()
