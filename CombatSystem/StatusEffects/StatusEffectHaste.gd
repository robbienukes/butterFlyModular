class_name StatusEffectHaste
extends StatusEffect

var speed_bonus := 0

var _stat_modifier_id := -1


func _init(target, data: StatusEffectData) -> void:
	super._init(target, data)
	id = "haste"
	speed_bonus = data.effect_power


func _start() -> void:
	_stat_modifier_id = _target.stats.add_modifier("speed", speed_bonus)
	print("Applied haste: modified speed of", _target, " to ", _target.stats.get_stat("speed"))



func _expire() -> void:	
	# Remove the speed modifier using the stored ID
	_target.stats.remove_modifier("speed", _stat_modifier_id)
	# Print the updated speed for debugging
	print("Haste expired: restored speed to", _target.stats.get_stat("speed"))
	# Free the node
	queue_free()
