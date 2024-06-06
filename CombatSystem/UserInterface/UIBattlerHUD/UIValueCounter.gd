# Animated counter for health and mana.
extends Label

# To differentiate the health and energy, I decided to use an enum. Its purpose
# is to preserve animations that are specific to the life counter, like when the
# health is low, and the label should blink red.
enum Type {HEALTH, ENERGY}

# I used the enum members as keys to assign a specific prefix to each type of
# counter.
const LABELS := {
	Type.HEALTH: "HP",
	Type.ENERGY: "EP"
}

# Rate of the animation relative to `max_value`. A value of 1.0 means the
# animation takes numbers from zero to the max_value in 1 second.
@export var fill_rate := 1.0
# I exported the type variable so we can easily set it on each instance. Using
# the `Type` enum as an export hint in parentheses results in a drop-down menu
# in the Inspector.
@export var type := Type.HEALTH

# As we extend the `Label` class, we don't have access to the `value` and
# `max_value` properties anymore, so we must define variables for them.
# We use a setter function for the `value` to update the label's `text` accordingly.
# We will also use the tween node to animate the text through this function.
var value := 0.0: set = set_value
var max_value := 0.0

# When this value changes, the counter smoothly animates towards that value
# using a tween.
var target_value := 0.0: set = set_target_value

@onready var _anim_player: AnimationPlayer = $CounterPlayer



# The setup function initialises the `max_value`, the `target_value`, and
# triggers an animation from `0` to `target_value`.
func setup(_value: float, _max_value: float) -> void:
	max_value = _max_value
	value = 0
	target_value = _value


func set_value(new_value: float) -> void:
	value = new_value
	# For the text, we use a string template. Each "%s" gets replaced by the
	# corresponding value in the following array.
	text = "%s: %s/%s" % [LABELS[type], round(value), round(max_value)]


# I only had to do minor changes to this function, highlighted by the comments
# below.
func set_target_value(amount: float) -> void:
	target_value = amount
	var _tween = create_tween()

	# As we now have two types of counters in one, we need to check for the type
	# before applying the damage animation.
	if target_value < value and type == Type.HEALTH:
		_anim_player.play("damage")

	if _tween.is_running():
		_tween.stop()

	var duration: float = abs(target_value - value) / max_value / fill_rate
	# An alternative to interpolating a value is to call
	# `Tween.interpolate_method()`. It calls the method every frame with a new
	# value. You can use it whenever a single tween should trigger multiple
	# changes at once.
	_tween.tween_method(set_value, value, target_value, duration).set_trans(Tween.TRANS_QUAD)
	_tween.play()


func _on_Tween_tween_completed(object: Object, key: NodePath) -> void:
	# There again, when the tween completes, we need to check for the counter's
	# type.
	if value < 0.2 * max_value and type == Type.HEALTH:
		_anim_player.play("danger")
