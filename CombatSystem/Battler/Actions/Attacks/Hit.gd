# Represents a damage-dealing hit to be applied to a target Battler.
# Encapsulates calculations for how hits are applied based on some properties.
class_name Hit
extends Node

# The damage dealt by the hit.
var damage := 0
# Chance to hit in base 100.
var hit_chance: float

var effect: StatusEffect

func _init(_damage: int, _hit_chance := 100.0, _effect: StatusEffect = null) -> void:
	damage = _damage
	hit_chance = _hit_chance
	effect = _effect
	
# Returns true if the hit isn't missing. To use when consuming the hit.
func does_hit() -> bool:
	return randf() * 100.0 < hit_chance
