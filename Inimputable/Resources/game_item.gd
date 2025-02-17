class_name GameItem
extends Resource

@export var game_item_name: String = ""
@export var game_item_id: String = ""
@export var game_item_description: String = ""
@export var game_item_icon: Texture2D # Icono para HUD/Inventario.
@export var game_item_type: String = "" # Tipo de objeto (weapon, ammo, health, etc).
@export var game_item_pickup_sound: AudioStream # Sonido al recoger el objeto por defecto
