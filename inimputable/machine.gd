extends Area3D




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	# Check if the collided body is the player
	if body.is_in_group("player"):
		Global.last_weapon = "machine"
		Global.current_weapon = "machine"
		

		queue_free()
