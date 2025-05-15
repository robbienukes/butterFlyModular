# Reactions.gd
# Handles reactions triggered by element interactions (e.g., wet + lightning)
class_name Reactions
extends Node

var _target: Battler = null

func setup(target: Battler) -> void:
	_target = target

func on_reacted_to(element: String) -> void:
	if element == "lightning":
		print("Checking for lightning reaction on", _target.name)
		
		if _target.has_status_effect("wet"):
			print("⚡ Wet + Lightning combo triggered on", _target.name)

			if _target.battler_anim:
				print("Has 'lightning' animation: ", _target.battler_anim.has_animation("lightning"))
				#_target.battler_anim.block_damage_animation = true
				_target.animation_player.play("lightning")
				_target.animation_player.seek(0.0, true)
				await _target.battler_anim.animation_finished
				_target.battler_anim.block_damage_animation = false
			else:
				push_error("❌ _target.battler_anim is null or undefined!")

			if _target.has_node("_status_effect_container"):
				var container := _target.get_node("_status_effect_container") as StatusEffectContainer
				container.remove_type("wet")
			else:
				push_warning("⚠️ Target has no _status_effect_container node.")
		else:
			print("❌ No wet status on", _target.name, "- no reaction triggered")
