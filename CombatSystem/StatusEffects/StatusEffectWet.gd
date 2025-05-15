class_name StatusEffectWet
extends StatusEffect

var speed_bonus := 0

var _stat_modifier_id := -1


func _init(target, data: StatusEffectData) -> void:
	super._init(target, data)
	id = "wet"
	speed_bonus = data.effect_power
	_can_stack = false


func _start() -> void:
	print("Applied wet status to ", _target)
	if _target.battler_anim.has_animation("wet"):
		_target.battler_anim.play("wet")

func react_to(element: String) -> void:
	on_reacted_to(element)


func _expire() -> void:	
	print("Wet expired on", _target)
	queue_free()
	
func on_reacted_to(element: String) -> void:
	if element == "lightning":
		print("⚡ Wet + Lightning combo triggered on", _target)

		# Play lightning animation ONLY on this battler
		if _target.battler_anim:
			print("→ battler_anim is: ", _target.battler_anim)
			print("→ Has 'lightning' animation: ", _target.battler_anim.has_animation("lightning"))
			_target.battler_anim.stop()
			_target.battler_anim.play("lightning")
			_target.battler_anim.seek(0.0, true)
		else:
			push_error("❌ _target.battler_anim is null or undefined!")

		# Properly remove the wet status using battler API
		if _target.has_method("remove_status_effect"):
			_target.remove_status_effect(self)
		else:
			push_warning("⚠️ Target does not support remove_status_effect()")
