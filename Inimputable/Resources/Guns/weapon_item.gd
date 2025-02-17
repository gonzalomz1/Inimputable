extends GameItem
class_name WeaponItem

@export var damage: int = 10
@export var fire_rate: float = 0.2
@export var chamber_capacity: int = 12
@export var ammo_capacity: int = 60
@export var is_automatic: bool = false
@export var reload_time: float = 1.0
@export var texture: Texture2D
@export var projectile_type: String = "hitscan" # puede ser hitscan o projectile
@export var sound_shoot: AudioStream
@export var sound_reload: AudioStream
@export var sound_empty: AudioStream
@export var idle_animation: StringName = "idle"
@export var reload_animation: StringName = "reload_per_magazine" # o, reload_per_bullet
@export var shoot_animation: StringName = "shoot"
@export var empty_animation: StringName = "empty"
