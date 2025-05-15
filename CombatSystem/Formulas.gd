class_name Formulas
extends Node

const Reactions = preload("res://CombatSystem/Battler/Reactions.gd")



# Returns the product of the attacker's attack and the action's multiplier.
static func calculate_potential_physical_damage(action_data, attacker) -> float:
	return attacker.stats.physical_attack * action_data.damage_multiplier


# Returns the product of the attacker's attack and the action's multiplier.
static func calculate_potential_magical_damage(action_data, attacker) -> float:
	return attacker.stats.magical_attack * action_data.damage_multiplier


# The base damage is "attacker.attack * action.multiplier - defender.defense".
# The function multiplies it by a weakness multiplier, calculated by
# `_calculate_weakness_multiplier` below. Finally, we ensure the value is an
# integer in the [1, 999] range.
static func calculate_base_physical_damage(action_data, attacker, defender) -> int:
	var damage: float = calculate_potential_physical_damage(action_data, attacker)
	damage -= defender.stats.physical_defense
	damage *= _calculate_weakness_multiplier(action_data, defender)
	return int(clamp(damage, 1.0, 999.0))
	
static func calculate_base_magical_damage(action_data, attacker, defender) -> int:
	var damage: float = calculate_potential_magical_damage(action_data, attacker)
	damage -= defender.stats.magical_defense
	damage *= _calculate_weakness_multiplier(action_data, defender)
	
	var reaction_map = ReactionData.get_reactions()

	var element_str = ActionData.Elements.keys()[action_data.element].to_lower()
	for status in defender.get_status_effects():
		var status_id = status.get_status_id()
		if reaction_map.has(status_id) and reaction_map[status_id].has(element_str):
			var reaction = reaction_map[status_id][element_str]
			damage *= reaction.multiplier
			Events.emit_signal("reaction_triggered", defender, status_id, element_str, reaction.sound)
			if status.has_method("on_reacted_to"):
				status.on_reacted_to(element_str)
	
	return int(clamp(damage, 1.0, 999.0))
# Calculates a multiplier based on the action and the defender's elements.
static func _calculate_weakness_multiplier(action_data, defender) -> float:
	var multiplier: float = 1.0
	var element: int = action_data.element
	if element != Types.Elements.NONE:
		# If the defender has an affinity with the action's element, the multiplier should be 0.75
		if Types.WEAKNESS_MAPPING[defender.stats.affinity] == element:
			multiplier = 0.75
		# If the action's element is part of the defender's weaknesses, we set the multiplier to 1.5
		elif Types.WEAKNESS_MAPPING[element] in defender.stats.weaknesses:
			multiplier = 1.5
	return multiplier

# The formula in pseudo-code:
# (attacker.hit_chance - defender.evasion) * action.hit_chance + affinity_bonus + element_triad_bonus - defender_affinity_bonus
static func calculate_hit_chance(action_data, attacker, defender) -> float:
	var chance: float = attacker.stats.hit_chance - defender.stats.evasion
	# The action's hit chance is a value between 0 and 100 for consistency with the battlers' stats.
	# As we use it as a multiplier here, we need to divide it by 100 first.
	chance *= action_data.hit_chance / 100.0

	# Below, we use the new BattlerStats properties, `affinity` and `weaknesses`, to apply a hit chance bonus or penalty.
	var element: int = action_data.element
	# If the action's element matches the attacker's affinity, we increase the hit rating by 5.
	if element == attacker.stats.affinity:
		chance += 5.0
	if element != Types.Elements.NONE:
		# If the action's element is part of the defender's weaknesses, we increase the hit rating by 10.
		if Types.WEAKNESS_MAPPING[element] in defender.stats.weaknesses:
			chance += 10.0
		# However, if the defender has an affinity with the action's element, we decrease the hit rating by 10.
		if Types.WEAKNESS_MAPPING[defender.stats.affinity] == element:
			chance -= 10.0
	# Clamping the result ensures it's always in the [0, 100] range.
	return clamp(chance, 0.0, 100.0)
