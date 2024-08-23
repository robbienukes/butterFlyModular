class_name StatusEffectReflect
extends StatusEffect

var _data: StatusEffectData

func _init(target, data: StatusEffectData) -> void:
	super._init(target, data)
	id = "reflect"
	_can_stack = false
	_data = data

func _start() -> void:
	pass
	
func _ready() -> void:
	var battler = _find_battler_node()

	if battler:
		# Use Callable to connect the signal to the method
		battler.hit_taken.connect(Callable(self, "on_hit_taken"))

func _find_battler_node() -> Node:
	# Get the grandparent node (battler_node)
	var parent_node = get_parent()
	if parent_node == null:
		return null
	
	var grandparent_node = parent_node.get_parent()
	if grandparent_node == null:
		return null

	return grandparent_node
	
func on_hit_taken(hit: Hit, action: Action) -> void:
	if action.is_reflected:
		print("Action already reflected, skipping to prevent infinite recursion.")
		return
	
	print("Hit taken by battler:", hit)
	print("Action that caused the hit:", action)
	# Add your custom logic here
	var battler_node = _find_battler_node()
	print("This is the battler node ",battler_node)
	if battler_node == null:
		print("Battler node not found")
		return

	var attacker = action._actor
	if attacker and attacker != battler_node:
		print("Reflecting action back to attacker:", attacker.name)

		var reflected_action = AttackAction.new(action._data, battler_node, [attacker])
		reflected_action.is_reflected = true

		print("Original actor:", action._actor.name)
		print("Reflected action set for actor:", reflected_action._actor.name)
		print("Targets for reflected action:", reflected_action._targets)

		reflected_action.apply_async()

		reflected_action.is_reflected = false
		battler_node.last_incoming_action = null

		#_play_reflect_animation()
	else:
		print("No valid attacker to reflect action to")

func _process(delta: float) -> void:
	if _data.effect_just_applied:
		print("Effect just applied")
		_data.effect_just_applied = false
		return

func _reflect_action(action: Action) -> void:
	if action.is_reflected:
		print("Action already reflected, skipping to prevent infinite recursion.")
		return
	
	var battler_node = _find_battler_node()
	print("This is the battler node ",battler_node)
	if battler_node == null:
		print("Battler node not found")
		return

	var attacker = action._actor
	if attacker and attacker != battler_node:
		print("Reflecting action back to attacker:", attacker.name)

		var reflected_action = Action.new(action._data, battler_node, [attacker])
		reflected_action.is_reflected = true

		print("Original actor:", action._actor.name)
		print("Reflected action set for actor:", reflected_action._actor.name)
		print("Targets for reflected action:", reflected_action._targets)

		reflected_action.apply_async()

		reflected_action.is_reflected = false
		battler_node.last_incoming_action = null

		#_play_reflect_animation()
	else:
		print("No valid attacker to reflect action to")


func _apply() -> void:
	pass 

func _expire() -> void:
	print("ReflectStatus expired on %s" % [_target.name])
	queue_free()
