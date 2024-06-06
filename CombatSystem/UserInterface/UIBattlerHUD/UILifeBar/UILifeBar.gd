extends TextureProgressBar


# Rate of the animation relative to `max_value`. A value of 1.0 means the animation fills the entire
# bar in one second.
@export var fill_rate := 1.0

# When this value changes, the bar smoothly animates towards it using a tween.
# See the setter function below for the details.
#var target_value := 0.0: set = set_target_value

@onready var _anim_player: AnimationPlayer = $AnimationPlayer


## We initialize the bar through a function because we need to set the `target_value` without
## passing through its setter function.
#func setup(health: float, max_health: float) -> void:
	#var _tween = create_tween()
	#max_value = max_health
	#value = health
	#target_value = health
	## We animate the bar using the `Tween` node. When the tween completes, we may need to play the
	## "danger" animation.
	#_tween.finished.connect(_on_Tween_tween_completed)




# When the tween animation completes, we play the "danger" animation if the battler's health is down
# to 20%.
func _on_Tween_tween_completed(object: Object, key: NodePath) -> void:
	if value < 0.2 * max_value:
		_anim_player.play("danger")
