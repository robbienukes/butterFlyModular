# HealAction.gd
class_name HealAction
extends Action

func apply_async() -> bool:
	for target in _targets:
		if not target:
			continue
		var stats = target.get_stats()
		if stats:
			stats.heal(_data.power)  # use power field

		var anim = target.get_anim()
		if anim and _data.animation != "":
			anim.play(_data.animation)

	await Engine.get_main_loop().process_frame
	emit_signal("finished")
	return true

func targets_opponents() -> bool:
	return false  # healing targets allies
