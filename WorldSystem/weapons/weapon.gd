class_name Weapon extends Node2D

@export var bullet_scene: PackedScene = preload("res://WorldSystem/weapons/bullets/bullet.tscn")
@export var weapon: WeaponData = null: set = set_weapon

@onready var _sprite_2d: Sprite2D = %Sprite2D
@onready var _audio_stream_player: AudioStreamPlayer2D = %AudioStreamPlayer2D
@onready var _bullet_spawn_point: Marker2D = $BulletSpawnPoint  # Adjust path if needed

## Maximum random angle applied to the shot bullets. Controls the gun's precision.
@export_range(0.0, 360.0, 1.0, "radians_as_degrees") var random_angle := PI / 12.0
## Maximum range a bullet can travel before it disappears.
@export_range(100.0, 2000.0, 1.0) var max_range := 2000.0
## The speed of the shot bullets
@export_range(100.0, 3000.0, 1.0) var max_bullet_speed := 1500.0


	## Makes the weapon shoot once. Override this function in scripts that inherit
## from this to create new weapons.
@export var bullet_data: BulletData

func _ready() -> void:
	set_weapon(weapon)
	
func shoot() -> void:
	var bullet = bullet_scene.instantiate() as Bullet

	bullet.bullet_data = bullet_data  # ✅ MUST BE SET FIRST!

	get_tree().current_scene.add_child(bullet)  # ✅ THEN add it to the tree

	bullet.global_position = _bullet_spawn_point.global_position
	bullet.rotation = _bullet_spawn_point.global_rotation
	bullet.rotation += randf_range(-random_angle / 2.0, random_angle / 2.0)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if weapon == null:
		warnings.append("The pickup has no item assigned. Please assign an item to the pickup in the inspector.")
	return warnings


func set_weapon(value: WeaponData) -> void:
	weapon = value
	if _sprite_2d != null:
		_sprite_2d.texture = weapon.texture
	if _audio_stream_player != null:
		_audio_stream_player.stream = weapon.sound_on_equip


func _physics_process(_delta: float) -> void:
	if not Engine.is_editor_hint() and Input.is_action_just_pressed("shoot"):
		shoot()
