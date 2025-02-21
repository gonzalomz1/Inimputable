extends Area3D




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	# Check if the collided body is the player
	if body.is_in_group("player"):
		
		$AudioStreamPlayer.play()
		Global.last_weapon = "mini"
		Global.current_weapon = "mini"

		



func _on_audio_stream_player_finished() -> void:
	queue_free()
