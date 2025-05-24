extends Resource
class_name MobData

@export var mob_name: String = "Red Blob"

@export var max_speed: float = 250.0
@export var acceleration: float = 700.0
@export var max_health: int = 3
@export var damage: int = 1
@export var sprite_frames: SpriteFrames  # ✅ THIS MUST EXIST
@export var death_sound: AudioStream
@export var flip_sprite: bool = true  # whether this mob should flip when moving left
@export var default_animation: String = "default"
