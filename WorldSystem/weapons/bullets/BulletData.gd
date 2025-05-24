extends Resource
class_name BulletData

@export var bullet_name: String = "Standard Bullet"

# Damage type using global Elements enum
@export_enum("NONE", "RAGE", "SERENITY", "ISOLATION", "CHAOS", "PRIDE", "WILL", "LIGHT", "CONDITION")
var element_type: int = Types.Elements.NONE

@export var main_texture: Texture2D
@export var effect_texture: Texture2D
@export var speed: float = 750.0
@export var base_damage: float = 1.0
@export var max_range: float = 1000.0
@export var fire_sound: AudioStream
@export var hit_sound: AudioStream
