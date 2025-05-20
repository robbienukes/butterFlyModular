class_name HealAction
extends Action

func apply_async() -> bool:
	for target in _targets:
		if not target:
			continue

		var is_zombie: bool = target.status.has_effect_type("zombie")
		var stats = target.get_stats()
		var amount = _data.power
		var label_type = UIDamageLabel.Types.HEAL  # default to green

		if is_zombie:
			print("💀 Target has Zombie! Healing becomes damage.")
			stats.take_damage(amount)
			label_type = UIDamageLabel.Types.DAMAGE  # force red
		else:
			stats.heal(amount)

		# ✅ Emit signal from the Battler, not from here
		target.damage_taken.emit(amount, label_type, target)

		var anim = target.get_anim()
		if anim and _data.animation != "":
			anim.play(_data.animation)

	await Engine.get_main_loop().process_frame
	emit_signal("finished")
	return true

func targets_opponents() -> bool:
	return false  # healing targets allies
