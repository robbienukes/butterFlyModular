# Hold and plays the base animation for battlers.
class_name BattlerAnim
extends Marker2D

# Forwards the animation players' `animation_finished` signal.
signal animation_finished(name)
# Emitted by animations when a combat action should apply its next effect, like dealing damage or healing an ally.
signal triggered

# There are two directions a battler can look: left or right. This enum represents that.
enum Direction { LEFT, RIGHT }

# Controls the direction in which the battler looks and moves.
# In `set_direction()`, we change the node's `scale.x` based on this property's valie.
@export var direction := Direction.RIGHT:
	set = set_direction

# We store the node's start position to reset it using the `Tween` node.
var _position_start := Vector2.ZERO

@onready var anim_player: AnimationPlayer = $Pivot/AnimationPlayer
@onready var anim_player_damage: AnimationPlayer = $Pivot/AnimationPlayerDamage
@onready var _anchor_front: Marker2D = $FrontAnchor
@onready var _anchor_top: Marker2D = $TopAnchor


func _ready() -> void:
	_position_start = position
	
func get_front_anchor_global_position() -> Vector2:
	return _anchor_front.global_position

func get_top_anchor_global_position() -> Vector2:
	return _anchor_top.global_position
	
	# Functions that wraps around the animation players' `play()` function, delegating the work to the
# `AnimationPlayerDamage` node when necessary.
func play(anim_name: String) -> void:
	if anim_name == "damage":
		anim_player_damage.play(anim_name)
		# Seeking back to 0 restarts the animation if it is already playing.
		anim_player_damage.seek(0.0)
	else:
		anim_player.play(anim_name)


# Wraps around `AnimationPlayer.is_playing()`
func is_playing() -> bool:
	return anim_player.is_running()


# Queues the animation and plays it if the animation player is stopped.
func queue_animation(anim_name: String) -> void:
	anim_player.queue(anim_name)
	if not anim_player.is_playing():
		anim_player.play()
		
		# The following two functions use the tween node to move the character forward and back.
# We'll use this to emphasize the start and end of a battler's turn.
func move_forward() -> void:
	var tween := create_tween()
	# The call below animates the node's position forward over `0.3` seconds.
	tween.tween_property(self, 'position',
	# We use `scale.x` to control the direction the node is facing.
	position + Vector2.LEFT * scale.x * 40.0, 0.3).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)


# Moves the node to `_position_start`
func move_back() -> void:
	var tween := create_tween() 
	tween.tween_property(
		self, 'position', _position_start, 0.3).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	emit_signal("animation_finished", anim_name)

# Set the direction and update the scale.x to flip the node
func set_direction(value: int) -> void:
	scale.x = 1.0 if value == Direction.RIGHT else -1.0
