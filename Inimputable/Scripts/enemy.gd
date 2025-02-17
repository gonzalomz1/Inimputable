class_name Enemy extends CharacterBody3D

@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D
@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("player")

@export var move_speed: float = 2.0
@export var attack_range: float = 2.0
@export var time_to_despawn: float = 5.0

var dead: bool = false

func _ready() -> void:
	$Timer.wait_time = time_to_despawn

func _physics_process(delta: float) -> void:
	if dead:
		return
	if player == null:
		return
	
	var dir = player.global_position - global_position
	dir.y = 0.0
	dir = dir.normalized()
	
	velocity = dir * move_speed
	move_and_slide()
	attempt_to_kill_player()

func attempt_to_kill_player() -> void:
	var dist_to_player = global_position.distance_to(player.global_position)
	if dist_to_player > attack_range:
		return
	
	var eye_line = Vector2.UP * 1.5
	var query = PhysicsRayQueryParameters3D.create(global_position + eye_line, player.global_position + eye_line, 1)
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		player.kill()

func kill() -> void:
	dead = true
	$DeathSound.play()
	animated_sprite_3d.play("death")
	collision_layer = 0
	$Timer.start()

func _on_timer_timeout() -> void:
	queue_free()
