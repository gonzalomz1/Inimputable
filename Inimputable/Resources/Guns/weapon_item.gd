extends GameItem
class_name WeaponItem

@export var damage: int = 10
@export var fire_rate: float = 0.2
@export var bullets: int
@export var chamber_capacity: int
@export var ammo_capacity: int
@export var is_automatic: bool
@export var reload_time: float
@export var texture: Texture2D
@export var projectile_type: String = "hitscan" # puede ser hitscan o projectile
@export var sound_shoot: AudioStream
@export var sound_reload: AudioStream
@export var sound_empty: AudioStream
