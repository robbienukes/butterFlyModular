# In-game arrow to select target battlers. Appears when the player selected an action and has to pick a target for it.
class_name UISelectBattlerArrow
extends Node2D

# Emitted when the player presses "ui_accept" or "ui_cancel".
signal target_selected(battler)

# Duration of the arrow's move animation in seconds.
@export var move_duration: float = 0.1

# Targets that the player can select. It's an array of Battler objects.
var _targets: Array
# Battler at which the arrow is currently pointing. If the player presses `ui_accept`, this battler will be selected.
# The setter calls the `_move_to()` function that moves the arrow to the target using a tween.
var _target_current: Battler: set = _set_target_current


# Similarly to the other arrow, we want this one to move independently of its parents.
func _init() -> void:
	set_as_top_level(true)


func _unhandled_input(event: InputEvent) -> void:
	# When the user presses enter or escape, we emit the "target_selected" signal.
	# Debug: Check if input is detected
	if event.is_action_pressed("ui_accept"):
		emit_signal("target_selected", [_target_current])
	elif event.is_action_pressed("ui_cancel"):
		# In the case the player cancels the selection, we emit an empty array for the targets,
		# which will cause the turn to restart and the game to re-open the action menu.
		emit_signal("target_selected", [])

	# If the player presses a direction input, we try to find a target in that direction.
	var new_target: Battler
	# We start by storing the direction as a Vector2.
	var direction := Vector2.ZERO
	if event.is_action_pressed("ui_left"):
		direction = Vector2.LEFT
	elif event.is_action_pressed("ui_up"):
		direction = Vector2.UP
	elif event.is_action_pressed("ui_right"):
		direction = Vector2.RIGHT
	elif event.is_action_pressed("ui_down"):
		direction = Vector2.DOWN
		
	# Debug: Check which direction is being pressed
	#print("Direction pressed: ", direction)

	# If the direction is not Vector2.ZERO, we try to find the closest target in that direction.
	# See `_find_closest_target()` below for more information.
	if direction != Vector2.ZERO:
		new_target = _find_closest_target(direction)
		if new_target:
			print("New target found: ", new_target)
			_set_target_current(new_target)
		else:
			print("No target found in direction: ", direction)


# Like all our UI components, we use a `setup()` function to initialize the arrow.
# I've decided to pass and store the battlers in this class for convenience because
# we need to know which battler the player selected. And due to the absence of buttons, we can't
# bind a reference to a signal callback like we did before.
func setup(battlers: Array) -> void:
	show()
	_targets = battlers
	print("Setup targets: ", _targets)
	_target_current = _targets[0]

	# You can use the arrow to select either an enemy or a party member.
	# We scale the node horizontally to flip it if targetting an ally.
	scale.x = 1.0 if _target_current.is_party_member else -1.0
	# This places the arrow in front of the current target battler.
	global_position = _target_current.battler_anim.get_front_anchor_global_position()


var _tween: Tween = null

# This function is similar to the one in `UIMenuSelectArrow` from the previous lesson.
# In this case though, we don't want other nodes to call it so we prepend the function with
# an underscore to mark it as pseudo-private.
func _move_to(target_position: Vector2):
	if _tween != null and _tween.is_running():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, 'position', target_position, move_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


# Returns the closest target in the given direction.
# Returns null if it cannot find a target in that direction.
func _find_closest_target(direction: Vector2) -> Battler:
	# We define our return variable and another to compare against battlers.
	var selected_target: Battler
	var distance_to_selected: float = INF

	# First, we find battlers in the given `direction`.
	var candidates := []
	for battler in _targets:
		# This filters out the `_target_current`.
		if battler == _target_current:
			continue
		# Then, we check if the target is at an angle of less than PI / 3 radians compared to
		# the `direction`. If so, it's a candidate for the current selection.
		var to_battler: Vector2 = battler.global_position - global_position
		var angle := direction.angle_to(to_battler)

		print("Battler position: ", battler.global_position)
		print("Arrow position: ", global_position)
		print("Direction: ", direction)
		print("To battler vector: ", to_battler)
		print("Angle to battler: ", angle)

		if abs(angle) < PI / 3.0:
			candidates.append(battler)
	
	print("Candidates found in direction ", direction, ": ", candidates)

	# We then find the closest battler among the `candidates`. That's the battler we want to select.
	for battler in candidates:
		var distance := global_position.distance_to(battler.global_position)
		if distance < distance_to_selected:
			selected_target = battler
			distance_to_selected = distance
	
	# Debug: Show selected target
	print("Selected target: ", selected_target)

	return selected_target


func _set_target_current(value: Battler) -> void:
	_target_current = value
	print("Setting target current to: ", _target_current)

	_move_to(_target_current.battler_anim.get_front_anchor_global_position())
