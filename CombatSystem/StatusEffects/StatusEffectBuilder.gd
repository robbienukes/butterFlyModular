# Creates concrete [StatusEffect] instances from [StatusEffectData] resources.
class_name StatusEffectBuilder
extends Node

# We register the valid ID strings for `StatusEffectData.id` in this constant.
# This allows us to not have to reference the class names directly and create new effect resources
# in the inspector.
# Note the convention in the GDScript style guide is to use PascalCase for types. I used that
# because our content is a map of types, but you may want to use constant case instead:
# `STATUS_EFFECTS`.
const StatusEffects := {
	"haste": preload("res://CombatSystem/StatusEffects/StatusEffectHaste.gd"),
	"slow": preload("res://CombatSystem/StatusEffects/StatusEffectSlow.gd"),
	"bug": preload("res://CombatSystem/StatusEffects/StatusEffectBug.gd"),
	"reflect": preload("res://CombatSystem/StatusEffects/StatusEffectReflect.gd"),
	"knockback": preload("res://CombatSystem/StatusEffects/StatusEffectKnockback.gd"),
	"wet": preload("res://CombatSystem/StatusEffects/StatusEffectWet.gd"),
	"zombie": preload("res://CombatSystem/StatusEffects/StatusEffectZombie.gd")
}


# The class only exposes a function that creates and returns a new status effect based on the data
# we provide.
static func create_status_effect(target, data):
	# We can use the function to run through some `assert()` or return early if the input parameters
	# are incorrect.
	if not data:
		return null
	# You can store a reference to a class in a variable!
	var effect_class = StatusEffects[data.effect]
	var effect: StatusEffect = effect_class.new(target, data)
	if target and effect:
		target._status_effect_container.add_child(effect)
	return effect
