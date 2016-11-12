extends Spatial

func _ready():
	get_node("Particles").set_emitting(true)
	var t=Tween.new()
	add_child(t)
	t.interpolate_callback(self,3,"_on_timeout")
	t.start()

func _on_timeout():
	queue_free()