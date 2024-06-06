class_name StatusEffectBug
extends StatusEffect

var damage := 3


# The parent class's constructor takes care of initializing ticking-related properties.
func _init(target, data) -> void:
	super._init(target, data)
	id = "bug"
	damage = data.ticking_damage
	# We set `_can_stack` to `true` so this effect can stack up to five times.
	# We'll see how in the next lesson.
	_can_stack = true


# On every tick, we deal damage to the target battler.
func _apply() -> void:
	_target.take_hit(Hit.new(damage))
