class_name Player extends CharacterBody3D

@onready var gun_scan: RayCast3D = $gun_scan
@onready var item_scan: RayCast3D = $item_scan
@onready var gun: Sprite2D = $CanvasLayer/GunBase/Gun
@onready var animations: AnimationPlayer = $CanvasLayer/GunBase/Animations
@onready var gun_sound: AudioStreamPlayer = $GunSound
@onready var fire_rate: Timer = $FireRate
@onready var reload_time: Timer = $ReloadTime
@onready var camera: Camera3D = $Camera3D
@onready var bulletsLabel: Label = $CanvasLayer/UI/Panel/bullets
@onready var ammoLabel: Label = $CanvasLayer/UI/Panel/ammo

const SPEED: float = 5.0
var mouse_sens: float = 0.5

var can_shoot: bool = true
var can_reload: bool = true
var is_reloading: bool = false
var dead: bool = false

var weapon: Array[WeaponItem]
var current_weapon: WeaponItem = null
var weapon_index: int = 0
var bullets: int = 0
var ammo: int = 0

# Vertical rotation limits (in degrees)
const MIN_VERTICAL_ANGLE: float = -90.0
const MAX_VERTICAL_ANGLE: float = 90.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$CanvasLayer/GunBase/DeathScreen/Panel/Restart.button_up.connect(restart)

func _input(event: InputEvent) -> void:
	if dead:
		return
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * mouse_sens
		# Rotación vertical (cámara)
		camera.rotation_degrees.x -= event.relative.y * mouse_sens
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, MIN_VERTICAL_ANGLE, MAX_VERTICAL_ANGLE)
		# Actualizar raycast
		update_raycasts()

func _process(delta: float) -> void:
	update_ui()
	if bullets == 12:
		can_reload = false
	else:
		can_reload = true
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("restart"):
		restart()
	## Todo lo que este por encima del "if dead" quiere decir que no es necesario que el jugador este activo para su funcionamiento
	if dead:
		return
	if Input.is_action_just_pressed("interact") and item_scan.is_colliding():
		var collider = item_scan.get_collider()
		if collider and collider.has_method("interact"):
			collider.interact(self) # Pasar el jugador como parametro 
	if weapon:
		if Input.is_action_just_pressed("reload"):
			reload()
		if can_shoot and !is_reloading:
			if Input.is_action_just_pressed("shoot"):
				shoot()


func _physics_process(delta: float) -> void:
	if dead:
		return
	var input_dir := Input.get_vector("move_left", "move_right", "move_forwards", "move_backwards")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()

func update_raycasts() -> void:
	# Obtener el transform global de la cámara
	var camera_transform = camera.global_transform
	# Actualizar posición y rotación de gun_scan
	gun_scan.global_transform.origin = camera_transform.origin
	gun_scan.global_transform.basis = camera_transform.basis
	# Actualizar posición y rotación de item_scan
	item_scan.global_transform.origin = camera_transform.origin
	item_scan.global_transform.basis = camera_transform.basis

func update_ui() -> void:
	bulletsLabel.text = str(bullets)
	ammoLabel.text = str(ammo)

func restart() -> void:
	get_tree().reload_current_scene()

func is_weapon_valid() -> bool:
	return current_weapon != null and current_weapon.texture != null

func reload() -> void:
	if !can_reload or !is_weapon_valid() or is_reloading:
		return
	if ammo <= 0 or bullets == current_weapon.chamber_capacity:
		return
	can_reload = false
	is_reloading = true
	animations.play(current_weapon.reload_animation)
	if current_weapon.sound_reload:
		gun_sound.stream = current_weapon.sound_reload
		gun_sound.play()
	reload_time.wait_time = current_weapon.reload_time
	reload_time.start()

func change_pos_and_hframes_gun_sprite(weapon_data: WeaponItem) -> void:
	if current_weapon.reload_animation == "reload_per_bullet":
		print("The current weapon has reload_per_bullet animation")
		gun.position.x = 725
		gun.position.y = 419
		gun.hframes = 10
	elif current_weapon.reload_animation == "reload_per_magazine":
		print("The current weapon has reload_per_magazine animation")
		gun.position.x = 725
		gun.position.y = 392
		gun.hframes = 16


func check_ammo() -> bool:
	return true

func shoot() -> void:
	if !can_shoot and !is_weapon_valid():
		return
	if bullets <= 0:
		# Sin balas
		can_reload = true
		animations.play(current_weapon.empty_animation)
		if current_weapon.sound_empty:
			gun_sound.stream = current_weapon.sound_empty
			gun_sound.play()
		## AGREGAR:
		# Si tiene balas restantes, intentar recargar.
		return
	can_shoot = false
	# Disparo normal
	bullets -= 1
	animations.play(current_weapon.shoot_animation)
	if current_weapon.sound_shoot:
		gun_sound.stream = current_weapon.sound_shoot
		gun_sound.play()
	# Verificar colision con gun_scan
	if gun_scan.is_colliding() and gun_scan.get_collider().has_method("kill"):
		gun_scan.get_collider().kill()
	# Temporizador para el tiempo entre disparos
	fire_rate.wait_time = current_weapon.fire_rate
	fire_rate.start()
	# Esperar a que el temporizador termine para permitir disparar de nuevo
	await fire_rate.timeout

func kill():
	dead = true
	$CanvasLayer/GunBase/DeathScreen.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func pickup_weapon(weapon_data: WeaponItem) -> void:
	var cloned = weapon_data.duplicate()
	if weapon_data.texture == null:
		print("No se puede equipar un arma sin textura.")
		return
	weapon.append(cloned)
	modify_current_weapon(cloned)

func modify_current_weapon(weapon_data: WeaponItem) -> void:
	current_weapon = weapon_data
	bullets = weapon_data.chamber_capacity
	ammo = weapon_data.ammo_capacity
	gun.texture = weapon_data.texture
	change_pos_and_hframes_gun_sprite(current_weapon)

func _on_animations_animation_finished(anim_name: StringName) -> void:
	can_shoot = true
	if anim_name == "reload":
		bullets = 12

func _on_fire_rate_timeout() -> void:
	can_shoot = true

func _on_reload_time_timeout() -> void:
	is_reloading = false
	var ammo_needed = current_weapon.chamber_capacity - bullets
	var ammo_to_reload = min(ammo_needed, ammo)
	bullets += ammo_to_reload
	ammo -= ammo_to_reload
	update_ui()
