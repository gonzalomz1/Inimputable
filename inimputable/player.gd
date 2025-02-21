extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const TURN_SPEED = 0.05
var knife_range = 3

@onready var ui_script = $UI
@onready var ray = $Camera3D/RayCast3D

var can_open_door = false

func _ready():
	add_to_group("player")
	Global.player = self
	#emit_signal("player_ready") # Emitimos la señal cuando el jugador está listo

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	#	velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	# add rotation
	if Input.is_action_pressed("ui_left"):
		self.rotate_y(TURN_SPEED)
	if Input.is_action_pressed("ui_right"):
		self.rotate_y(-TURN_SPEED)
		
	if Input.is_action_pressed("ui_accept"):
		if ui_script.can_shoot:
			shoot()
		
	#print("Posición antes de mover: ", global_position)
	move_and_slide()
	#print("Nueva posición del enemigo: ", global_position)


func shoot():
	var sound_player = $AudioStreamPlayer  # Adjust this to your node path

	match Global.current_weapon:
		"knife":
			sound_player.stream = preload("res://asset/Knife.wav")
		"gun":
			sound_player.stream = preload("res://asset/gun.ogg")
		"machine":
			sound_player.stream = preload("res://asset/machine.ogg")
		"mini":
			sound_player.stream = preload("res://asset/mini.ogg")

	sound_player.play()

	
	
	#if ray.is_colliding() and ray.get_collider().has_method("die"):
	#	ray.get_collider().die()
	
	if ray.is_colliding():
		var collider = ray.get_collider()
		var distance_to_collider = global_position.distance_to(collider.global_position)

		if Global.current_weapon == "knife" and distance_to_collider > knife_range:
			return
		else:
			if collider.has_method("take_damage"):
				collider.take_damage()

		
		
func damage():
	Global.player_health -= 10
	print(Global.player_health)
	if Global.player_health <= 0:
		if Global.lives <= 1:
			queue_free()
		else:
			Global.lives -= 1
			Global.player_health = 100
			Global.current_weapon = "gun"
			Global.ammo = 10
			get_tree().change_scene_to_file("res://world.tscn")
			Global.player_health = 100
