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
var is_changing_weapon: bool = false
var dead: bool = false

var pistol: WeaponItem = null
var shotgun: WeaponItem = null
var melee: WeaponItem = null

var current_weapon: WeaponItem = null

var weapons: Dictionary = {
	"1": pistol,
	"2": shotgun
}

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
	if Input.is_action_just_pressed("1") and pistol != null and !is_reloading:
			modify_current_weapon(pistol)
			return
	if Input.is_action_just_pressed("2") and shotgun != null and !is_reloading:
			modify_current_weapon(shotgun)
			return
	if current_weapon != null and !is_changing_weapon:
		if Input.is_action_just_pressed("reload"):
			reload()
		if can_shoot and !is_reloading:
			if Input.is_action_just_pressed("shoot"):
				shoot()
		if current_weapon.bullets == current_weapon.chamber_capacity:
			can_reload = false
		else:
			can_reload = true


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
	if current_weapon != null:
		bulletsLabel.text = str(current_weapon.bullets)
		ammoLabel.text = str(current_weapon.ammo_capacity)

func restart() -> void:
	get_tree().reload_current_scene()

func is_weapon_valid() -> bool:
	return current_weapon != null and current_weapon.texture != null

func reload() -> void:
	if !can_reload or !is_weapon_valid() or is_reloading:
		return
	if current_weapon.ammo_capacity <= 0 or current_weapon.bullets == current_weapon.chamber_capacity:
		return
	can_reload = false
	is_reloading = true
	animations.play("reload_" + current_weapon.game_item_name)
	if current_weapon.sound_reload:
		gun_sound.stream = current_weapon.sound_reload
		gun_sound.play()
	reload_time.wait_time = current_weapon.reload_time
	reload_time.start()

func change_pos_and_hframes_gun_sprite(weapon_data: WeaponItem) -> void:
	match current_weapon.game_item_name:
		"pistol":
			gun.position.x = 725
			gun.position.y = 392
			gun.hframes = 17
		"shotgun":
			gun.position.x = 725
			gun.position.y = 419
			gun.hframes = 14

func check_ammo() -> bool:
	return true

func shoot() -> void:
	if !can_shoot and !is_weapon_valid():
		return
	if current_weapon.bullets <= 0:
		# Sin balas
		can_reload = true
		animations.play("empty_" + current_weapon.game_item_name)
		if current_weapon.sound_empty:
			gun_sound.stream = current_weapon.sound_empty
			gun_sound.play()
		## AGREGAR:
		# Si tiene balas restantes, intentar recargar.
		return
	can_shoot = false
	# Disparo normal
	current_weapon.bullets -= 1
	animations.play("shoot_" + current_weapon.game_item_name)
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
	var cloned: WeaponItem = weapon_data.duplicate()
	if weapon_data.texture == null:
		printerr("No se puede equipar un arma sin textura.")
		return
	assign_new_weapon_to_slot(cloned)

func assign_new_weapon_to_slot(weapon_data: WeaponItem) -> void:
	match weapon_data.game_item_name:
		"pistol":
			pistol = weapon_data
		"shotgun":
			shotgun = weapon_data

func modify_current_weapon(weapon_data: WeaponItem) -> void:
	is_changing_weapon = true
	current_weapon = weapon_data
	gun.texture = weapon_data.texture
	animations.play("change_weapon_" + current_weapon.game_item_name)
	change_pos_and_hframes_gun_sprite(current_weapon)

func _on_animations_animation_finished(anim_name: StringName) -> void:
	if !is_reloading:
		can_shoot = true

func _on_fire_rate_timeout() -> void:
	can_shoot = true

func _on_reload_time_timeout() -> void:
	if current_weapon.game_item_name == "shotgun":
		need_bolt()
	else:
		is_reloading = false
		var ammo_needed = current_weapon.chamber_capacity - current_weapon.bullets
		var ammo_to_reload = min(ammo_needed, current_weapon.ammo_capacity)
		current_weapon.bullets += ammo_to_reload
		current_weapon.ammo_capacity -= ammo_to_reload
		update_ui()

func back_to_idle() -> void:
	animations.play("idle_" + current_weapon.game_item_name)

func finished_changing_weapon() -> void:
	is_changing_weapon = false

func need_bolt() -> void:
	if current_weapon.bullets < current_weapon.chamber_capacity:
		animations.play("reload_" + current_weapon.game_item_name)
	else:
		animations.play("bolt_" + current_weapon.game_item_name)
