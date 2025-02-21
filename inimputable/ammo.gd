extends Area3D


func _on_body_entered(body):
	# Check if the collided body is the player
	if body.is_in_group("player") and Global.ammo < 100:

		# Increment the global ammo variable by 10
		Global.ammo += 10  # Assuming Global is the name of your global script
		$AudioStreamPlayer.play()
		Global.current_weapon = Global.last_weapon
		queue_free()




func _on_audio_stream_player_finished() -> void:
	queue_free()
