class_name StatusEffectKnockback
extends StatusEffect

var _data: StatusEffectData

var _knockback_amount: int = 25

func _init(target, data: StatusEffectData) -> void:
	super._init(target, data)
	id = "knockback"
	_can_stack = false
	_data = data

func _start() -> void:
	pass
	
func _ready() -> void:
	var battler = _find_battler_node()

	if battler:
		# Use Callable to connect the signal to the method
		battler._set_readiness(battler._readiness - _knockback_amount)

func _find_battler_node() -> Node:
	# Get the grandparent node (battler_node)
	var parent_node = get_parent()
	if parent_node == null:
		return null
	
	var grandparent_node = parent_node.get_parent()
	if grandparent_node == null:
		return null

	return grandparent_node




func _apply() -> void:
	pass 

func _expire() -> void:
	print("Knockback expired on %s" % [_target.name])
	queue_free()
