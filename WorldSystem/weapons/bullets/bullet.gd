extends Area2D
class_name Bullet

@export var speed: float = 750.0
@export var base_damage: float = 1.0
@export var max_range: float = 1000.0

# Expose textures for each sprite (optional)
@export var main_texture: Texture2D
@export var effect_texture: Texture2D

# Optional audio
@export var fire_sound: AudioStream
@export var hit_sound: AudioStream

var _traveled_distance := 0.0

func _ready() -> void:
	# Apply visual customization
	if main_texture:
		$Sprite2D_Main.texture = main_texture
	if effect_texture:
		$Sprite2D_Effect.texture = effect_texture

	# Connect body_entered signal
	body_entered.connect(_on_body_entered)

	# Play fire sound
	if fire_sound:
		var player = AudioStreamPlayer2D.new()
		player.stream = fire_sound
		player.position = global_position
		get_tree().current_scene.add_child(player)
		player.play()

func _physics_process(delta: float) -> void:
	var distance = speed * delta
	var motion = Vector2.RIGHT.rotated(rotation) * distance
	position += motion

	_traveled_distance += distance
	if _traveled_distance > max_range:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.has_method("set_health"):
		body.set_health(body.health - base_damage)

	if hit_sound:
		var player = AudioStreamPlayer2D.new()
		player.stream = hit_sound
		player.position = global_position
		get_tree().current_scene.add_child(player)
		player.play()

	queue_free()
