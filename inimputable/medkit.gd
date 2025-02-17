extends Area3D







func _on_body_entered(body: Node3D) -> void:
	# Check if the collided body is the player
	if body.is_in_group("player") and Global.player_health < 100:
		$AudioStreamPlayer.play()  # Call play as a function

		# Increase the player health by 25, but do not exceed 100
		Global.player_health = min(Global.player_health + 25, 100)
		
		# Disable the area to prevent multiple triggers
		set_deferred("monitoring", false)



func _on_audio_stream_player_finished() -> void:
	queue_free()
