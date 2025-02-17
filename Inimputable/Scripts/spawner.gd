extends Marker3D

@export var enemy_scene: PackedScene
@export var spawn_time: float = 5.0

var enemies: Array[Enemy]
var spawn_active: bool = true

func _ready() -> void:
	if enemy_scene:
		print("in " + name + " the enemy scene has been loaded: " + str(enemy_scene))
	$Timer.wait_time = spawn_time
	$Timer.start()

func spawn() -> void:
	var new_spawn = enemy_scene.instantiate()
	enemies.append(new_spawn)
	add_child(new_spawn)

func _on_timer_timeout() -> void:
	print("Timer on spawner: TIMEOUT!")
	spawn()
