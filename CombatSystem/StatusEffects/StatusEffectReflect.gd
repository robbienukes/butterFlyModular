class_name StatusEffectReflect
extends StatusEffect


func _init(target, data: StatusEffectData) -> void:
	super._init(target, data)
	id = "reflect"
	_can_stack = false

func _start() -> void:
	# Locate the nearest BattlerAnim node in the scene tree from the current node
	var current_node = self
	
	# get the parent node
	var parent_node = current_node.get_parent()
	if parent_node: 
		# get the aprent of the parent
		var grandparent_node = parent_node.get_parent()
		
		if grandparent_node.name == "BattlerAnim":
			grandparent_node.play("reflect")
			# Testing
			var test_reflect_anim = true;
		
		else:
			print("Player not found")
	else:
		print("No parent")	
			

# Override the apply method to reflect the status effect back to the attacker
func _apply() -> void:
	# This effect doesn't apply anything on ticking intervals, so we leave this empty
	pass

# Override the expire method to clean up when the status effect expires
func _expire() -> void:
	print("ReflectStatus expired on %s" % [_target.name])
	queue_free()
