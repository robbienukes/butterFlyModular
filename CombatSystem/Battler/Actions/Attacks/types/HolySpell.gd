class_name HolySpell
extends AttackAction

func _init(data: AttackActionData, actor, targets: Array) -> void:
	print("🌟 HolySpell instantiated for:", actor.name)
	super._init(data, actor, targets)


func apply_async() -> bool:
	print("🌟 HolySpell apply_async called by:", _actor.name, "on targets:", _targets)

	await super.apply_async()
	
	for target in _targets:
		if target.has_status_effect("zombie"):
			var container: StatusEffectContainer = target.get_node("_status_effect_container")
			if container:
				container.remove_type("zombie")
				print("💫 HolySpell: Removed zombie status from", target.name)
			else:
				push_warning("⚠️ No status container on target for HolySpell")
				
	return true
