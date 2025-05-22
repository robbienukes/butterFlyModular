class_name Bullet extends Area2D

@export var speed := 750
@export var base_damage := 1

var max_range := 1000.0
var _traveled_distance = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is Mob:
		body.set_health(body.health - base_damage)
		_destroy()




func _physics_process(delta: float) -> void:
	var distance := speed * delta
	var motion := Vector2.RIGHT.rotated(rotation) * distance

	position += motion

	_traveled_distance += distance
	if _traveled_distance > max_range:
		_destroy()


func _destroy():
	queue_free()
