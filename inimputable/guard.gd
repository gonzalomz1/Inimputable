extends CharacterBody3D

#@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")

@onready var player = get_node("../player") as CharacterBody3D

const SPEED = 1
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")  # Get the gravity from the project settings to be synced with RigidBody nodes.
var dead = false
var is_attacking = false  
var attack_range = 3

func _ready():
	add_to_group("enemy")

func _physics_process(delta):
	print("Llamando a _physics_process()")
	if dead or is_attacking:  # Check if the enemy is dead or attacking
		return

	if player == null:
		return
		print("Player no es nulo")
		
	var dir = player.global_position - global_position
	
	#antes
	#dir.y = 0.0
	#dir = dir.normalized()
	
	#agregue
	dir.y = 0.0  # Eliminamos la componente Y *antes* de normalizar

	if dir.length() > 0: # Check if the direction vector is not zero
		dir = dir.normalized() # Normalizamos *después* de eliminar la componente Y
		velocity = dir * SPEED
		
	else:
		velocity = Vector3.ZERO # If the direction is zero, the velocity must be zero too

	
	
	print("la direccion es ",dir)
	
	
	
	velocity = dir * SPEED
	
	print("la velocidad del enemigo es", velocity)
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		#velocity -= gravity * delta
		#velocity = get_gravity() * delta

	#look_at(player.global_position)
	print("Antes de move_and_slide()", velocity)
	move_and_slide()
	print("Después de move_and_slide()", velocity)
	attack()

func attack():
	var dist_to_player = global_position.distance_to(player.global_position)
	if dist_to_player > attack_range:
		return
		
	# NEW BLOCK OF CODE TO RE-AIM IF PLAYER MOVES #
	var dir = player.global_position - global_position
	dir.y = 0.0
	dir = dir.normalized()
	rotation.y = atan2(dir.x, dir.z)
	# END NEW BLOCK #
	is_attacking = true  # Set the attacking flag
	$AnimatedSprite3D.play("shoot")
	$AudioStreamPlayer2.play()
	if $RayCast3D.is_colliding() and $RayCast3D.get_collider().has_method("damage"):
		$RayCast3D.get_collider().damage()
	await $AnimatedSprite3D.animation_finished  # Wait for the animation to finish
	is_attacking = false  # Reset the attacking flag


func die():
	dead = true  # Corrected variable scope
	Global.player_score += 100
	$AnimatedSprite3D.play("die")
	$AudioStreamPlayer.play()
	$CollisionShape3D.disabled = true
