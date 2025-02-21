extends StaticBody3D

@onready var animation_player = $AnimationPlayer
@onready var area = $Area3D
var is_open = false


func _input(event):
	if event.is_action_pressed("ui_focus_next") and not is_open:
		print("Opening door")
		open_door()

func open_door():
	is_open = true
	$CollisionShape3D.disabled = true
	animation_player.play("open")
	print("Door opened")
	

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.set("can_open_door", true)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.set("can_open_door", false)
		print("Player range left of door")
