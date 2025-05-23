extends AnimatedSprite2D

const SPRITE_RIGHT := preload("res://WorldSystem/player/godot_right.png")
const SPRITE_DOWN := preload("res://WorldSystem/player/godot_bottom.png")
const SPRITE_UP := preload("res://WorldSystem/player/godot_up.png")
const SPRITE_DOWN_RIGHT := preload("res://WorldSystem/player/godot_bottom_right.png")
const SPRITE_UP_RIGHT := preload("res://WorldSystem/player/godot_up_right.png")

const UP_RIGHT = Vector2.UP + Vector2.RIGHT
const UP_LEFT = Vector2.UP + Vector2.LEFT
const DOWN_RIGHT = Vector2.DOWN + Vector2.RIGHT
const DOWN_LEFT = Vector2.DOWN + Vector2.LEFT


func _process(delta: float) -> void:
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	var direction_discrete := input_direction.sign()
	match direction_discrete:
		Vector2.LEFT, Vector2.RIGHT:
			play("runLeft")
		Vector2.UP:
			play("runUp")
		Vector2.DOWN:
			play("runDown")
		
	if direction_discrete.length() > 0:
		flip_h = direction_discrete.x > 0.0
