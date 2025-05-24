extends Node2D
class_name Bullet

@export var bullet_data: BulletData

@export var speed: float = 750.0
@export var base_damage: float = 1.0
@export var max_range: float = 1000.0

var _traveled_distance := 0.0

func _ready() -> void:
	print(">>> BULLET _ready() called")
	set_physics_process(true)  # Force-enable physics processing

	print("Bullet in tree:", is_inside_tree(), " | Processing:", is_physics_processing())

	if bullet_data == null:
		push_error("BulletData not assigned!")
		return

	# Apply visual customization
	$Sprite2D_Main.texture = bullet_data.main_texture
	$Sprite2D_Effect.texture = bullet_data.effect_texture
	$HitBox.body_entered.connect(_on_body_entered)

	# Play fire sound
	if bullet_data.fire_sound:
		var player = AudioStreamPlayer2D.new()
		player.stream = bullet_data.fire_sound
		player.position = global_position
		get_tree().current_scene.add_child(player)
		player.play()

	# Connect signal
	#body_entered.connect(_on_body_entered)
	
func _physics_process(delta: float) -> void:
	if bullet_data == null:
		push_error("BulletData not assigned in _physics_process!")
		queue_free()
		return

	var distance = bullet_data.speed * delta
	position += Vector2.RIGHT.rotated(rotation) * distance
	_traveled_distance += distance

	if _traveled_distance >= max_range:
		print("💥 Bullet exceeded range. Destroying.")
		queue_free()


func _on_body_entered(body: Node) -> void:
	print("BULLET HIT:", body.name)

	if body.has_method("set_health"):
		body.set_health(body.health - bullet_data.base_damage)
		print("Bullet name:", bullet_data.bullet_name)
		print("Element:",Types.Elements.keys()[bullet_data.element_type])
	if bullet_data.hit_sound:
		var player = AudioStreamPlayer2D.new()
		player.stream = bullet_data.hit_sound
		player.position = global_position
		get_tree().current_scene.add_child(player)
		player.play()

	queue_free()
