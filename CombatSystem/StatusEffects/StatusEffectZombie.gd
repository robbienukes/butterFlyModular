class_name StatusEffectZombie
extends StatusEffect

func _init(target, data):
	super._init(target, data)
	id = "zombie"
	# We set `_can_stack` to `true` so this effect can stack up to five times.
	_can_stack = false



func get_effect_type() -> String:
	return "zombie"

func blocks_revive() -> bool:
	return true

func is_healing_inverted() -> bool:
	return true
