extends StatusEffect

class_name ReflectStatus

# Override the start method to initialize the reflect status effect
func _start() -> void:
	print("ReflectStatus applied to %s" % [_target.name])

# Override the apply method to reflect the status effect back to the attacker
func _apply() -> void:
	# This effect doesn't apply anything on ticking intervals, so we leave this empty
	pass

# Override the expire method to clean up when the status effect expires
func _expire() -> void:
	print("ReflectStatus expired on %s" % [_target.name])
	queue_free()
