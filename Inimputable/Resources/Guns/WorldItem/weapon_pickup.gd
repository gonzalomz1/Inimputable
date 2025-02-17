extends Area3D

class_name WeaponPickup

@export var weapon_data: WeaponItem # Recurso que contiene los datos del arma 

@onready var sprite_3d: Sprite3D = $Sprite3D

func _ready() -> void:
	if weapon_data:
		print("Arma spawneada: " + weapon_data.game_item_name)
		sprite_3d.texture = weapon_data.game_item_icon

func _on_body_entered(body) -> void:
	if body.has_method("pickup_weapon"):
		body.pickup_weapon(weapon_data)
		queue_free()

func interact(player: CharacterBody3D) -> void:
	if player.has_method("pickup_weapon"):
		player.pickup_weapon(weapon_data)
		queue_free()
