# Data container used to construct [AttackAction] objects.
class_name AttackActionData
extends ActionData


# Multiplier applied to the calculated attack damage.
@export var damage_multiplier := 1.0
# Hit chance rating for this attack. Works as a rate: a value of 90 means the
# action has a 90% chance to hit.
@export var hit_chance := 100.0

# Status effect applied by the attack, of type `StatusEffectData`.
@export var status_effect: Resource

@export var does_damage := true

@export var hit_sound: AudioStream
@export var hit_confirm_sound: AudioStream
@export var miss_sound: AudioStream




# Returns the total damage for the action, factoring in damage dealt by a status effect.
func calculate_potential_damage_for(battler) -> int:
	var total_physical_damage: int = int(Formulas.calculate_potential_physical_damage(self, battler))
	var total_magical_damage: int = int(Formulas.calculate_potential_magical_damage(self, battler))
	var total_damage:= total_physical_damage + total_magical_damage
	# Adding the effect's damage if applicable.
	if status_effect:
		total_damage += status_effect.calculate_total_damage()
	return total_damage
