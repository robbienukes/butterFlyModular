# Arrow to select actions in a [UIActionList].
extends Marker2D

var tween: Tween = null

# The arrow needs to move indepedently from its parent.
func _init() -> void:
	set_as_top_level(true)


func move_to(target: Vector2) -> void:
	if tween != null and tween.is_running():
		tween.kill()
	var tween = create_tween()
	tween.tween_property(self, 'position', target, 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

