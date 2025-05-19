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
		battler.hit_taken.connect(Callable(self, "on_hit_taken"))

func _find_battler_node() -> Node:
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
	
	var battler_node = _find_battler_node()
	if battler_node == null:
		print("Battler node not found")
		return
		
	if action._data is AttackActionData and not action._data.is_magical:
		print("Not a magical action. Reflection skipped.")
		return

	var attacker = action._actor
	if attacker and attacker != battler_node:
		print("Reflecting action back to attacker:", attacker.name)

		var reflected_action = AttackAction.new(action._data.duplicate(), battler_node, [attacker])
		reflected_action.is_reflected = true

		get_tree().current_scene.add_child(reflected_action)
		await reflected_action.apply_async()
		reflected_action.queue_free()

		print("🎵 hit_confirm_sound on reflect:", action._data.hit_confirm_sound)


		# ✅ Resume original attacker’s turn flow
		if attacker.has_method("move_back"):
			attacker.move_back()

		if attacker.has_method("_set_readiness"):
			attacker._set_readiness(reflected_action.get_readiness_saved())

		if attacker.has_method("set_process"):
			attacker.set_process(true)

		if attacker.has_signal("action_finished"):
			attacker.action_finished.emit()

		battler_node.last_incoming_action = null
	else:
		print("No valid attacker to reflect action to")

func _process(delta: float) -> void:
	if _data.effect_just_applied:
		print("Effect just applied")
		_data.effect_just_applied = false
		return

func _apply() -> void:
	pass 

func _expire() -> void:
	print("ReflectStatus expired on %s" % [_target.name])
	queue_free()
