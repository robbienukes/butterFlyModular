class_name Player
extends CharacterBody2D


@export var speed := 230.0
@export var drag_factor := 10.0
@export var max_health := 10

@onready var health := max_health: set = set_health

@onready var _health_bar: ProgressBar = %HealthBar
@onready var _collision_shape_2d: CollisionShape2D = %CollisionShape2D


func _ready() -> void:
	_health_bar.max_value = max_health
	_health_bar.value = health

func _physics_process(delta: float) -> void:
	var move_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var desired_velocity := speed * move_direction
	var steering := desired_velocity - velocity
	velocity += steering * drag_factor * delta
	move_and_slide()  # No arguments here

	
	
func set_health(new_health: int) -> void:
	var previous_health := health
	health = clampi(new_health, 0, max_health)
	_health_bar.value = health

	if health == 0:
		die()


func die() -> void:
	queue_free()
