class_name AttackActionData
extends ActionData

@export var damage_multiplier := 1.0
@export var hit_chance := 100.0
@export var status_effect: Resource
@export var does_damage := true
@export var hit_sound: AudioStream
@export var hit_confirm_sound: AudioStream
@export var miss_sound: AudioStream

# ✅ Add this to allow custom action scripts
@export var action_script: Script

func calculate_potential_damage_for(battler) -> int:
	var total_physical_damage: int = int(Formulas.calculate_potential_physical_damage(self, battler))
	var total_magical_damage: int = int(Formulas.calculate_potential_magical_damage(self, battler))
	var total_damage:= total_physical_damage + total_magical_damage
	if status_effect:
		total_damage += status_effect.calculate_total_damage()
	return total_damage
