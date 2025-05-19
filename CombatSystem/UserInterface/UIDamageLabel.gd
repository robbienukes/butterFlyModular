# Animated label displaying amounts of damage or healing.
class_name UIDamageLabel
extends Node2D

# We use the Types enum to control the Label's color, using the colors below.
enum Types { HEAL, DAMAGE }

const COLOR_TRANSPARENT := Color(1.0, 1.0, 1.0, 0.0)

# By exporting these two colors, we can edit them in the Inspector using a color picker. You could
# use constants instead.
@export var color_damage := Color("#b0305c")
@export var color_heal := Color("#3ca370")

# The actual color applied to the Label node's text via its `modulate` property.
var _color: Color: set = _set_color
# This is the number displayed on the Label. We store it in a variable so we can call the `setup()`
# function below before adding the node to the tree, which is when we set the Label's text and start
# the animation.
var _amount := 0

var _type:= Types.DAMAGE

@onready var _label: Label = $Label



# Below, `type` should be a member of the `Types` enum.
func setup(type: int, start_global_position: Vector2, amount: int) -> void:
	global_position = start_global_position
	_amount = amount
	_type = type

	match type:
		Types.DAMAGE:
			_set_color(color_damage)
		Types.HEAL:
			_set_color(color_heal)


func _ready() -> void:
	match _type:
		Types.DAMAGE:
			_label.text = "-%d" % abs(_amount)
		Types.HEAL:
			_label.text = "+%d" % abs(_amount)
	_animate()



func _set_color(value: Color) -> void:
	_color = value
	# Once more, we need a setter for the `_color` property to trigger a change in the Label node.
	if not is_inside_tree():
		await ready
	_label.modulate = _color


# Animates the node flying up in a random direction.
func _animate() -> void:
	var _tween = create_tween()
	
	# We define a range of 120 degrees for the direction in which the node can fly.
	var angle := randf_range(-PI / 3.0, PI / 3.0)
	# And we calculate an offset vector from that.
	var offset := Vector2.UP.rotated(angle) * 60.0

	# The Tween node takes care of animating the Label's `rect_position` over 0.4 seconds. It's a
	# bit faster than the miss label and uses an ease-out so the animation feels dynamic.
	_tween.tween_property(_label,
	"position",
	_label.position + offset,
	0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# The fade-out animation starts after a 0.3 seconds delay and lasts 0.1 seconds.
	# This makes it so the Label quickly fades out and disappears at the end.
	_tween.tween_property(_label, "modulate", COLOR_TRANSPARENT, 0.1).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	# We finally wait for all tweens to complete before freeing the node.
	await _tween.finished
	queue_free()
