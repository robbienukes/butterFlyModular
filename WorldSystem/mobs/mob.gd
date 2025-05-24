extends CharacterBody2D
class_name Mob

@export var mob_data: MobData

var health: int
var _player: Player = null

@onready var _detection_area: Area2D = %DetectionArea
@onready var _hit_box: Area2D = %HitBox
@onready var _sprite: AnimatedSprite2D = %AnimatedSprite2D

func _ready() -> void:
	# Connect detection area signal (TEMP: skip class check for debugging)
	_detection_area.body_entered.connect(func(body: Node) -> void:
		print("📍 Detected body:", body.name, " class:", body.get_class())
		_player = body
	)

	_detection_area.body_exited.connect(func(body: Node) -> void:
		if body == _player:
			print("🚪 Player exited detection area.")
			_player = null
	)

	_hit_box.body_entered.connect(func(body: Node) -> void:
		if mob_data and body is Player:
			body.health -= mob_data.damage
	)

	# Initialize mob visuals and state
	if mob_data == null:
		push_error("MobData not assigned!")
		return

	_sprite.frames = mob_data.sprite_frames
	_sprite.play(mob_data.default_animation)
	health = mob_data.max_health


func set_health(new_health: int) -> void:
	health = new_health
	if health <= 0:
		die()


func die() -> void:
	if mob_data.death_sound:
		var sfx = AudioStreamPlayer2D.new()
		sfx.stream = mob_data.death_sound
		sfx.position = global_position
		get_tree().current_scene.add_child(sfx)
		sfx.play()
	queue_free()

func _physics_process(delta: float) -> void:
	print("🧠 _player =", _player)

	if mob_data == null:
		return

	if _player == null:
		velocity = velocity.move_toward(Vector2.ZERO, mob_data.acceleration * delta)
	else:
		var direction = global_position.direction_to(_player.global_position)
		var distance = global_position.distance_to(_player.global_position)
		var speed = mob_data.max_speed if distance > 120.0 else mob_data.max_speed * distance / 120.0

		var desired_velocity = direction * speed
		velocity = velocity.move_toward(desired_velocity, mob_data.acceleration * delta)

		print("➡️ Moving toward player. Velocity:", velocity, " Direction:", direction)

		# Flip sprite
		if mob_data.flip_sprite:
			_sprite.flip_h = velocity.x < -10.0

	print("➡️ Final move velocity:", velocity)
	move_and_slide()
