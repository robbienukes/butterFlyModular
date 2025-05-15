# Keeps track of status effects active on a [Battler].
# Adds and removes status effects as necessary.
# Intended to be placed as a child of a Battler.
class_name StatusEffectContainer
extends Node

# signals for adding and removing ststaus effects
signal status_effect_added(effect: StatusEffect)
signal status_effect_removed(effect: StatusEffect)


# Maximum number of instances of one type of status effect that can be applied to one battler at a
# time.
const MAX_STACKS := 5
# List of effects that can be stacked.
const STACKING_EFFECTS := ["bug"]
# List of effects that cannot be stacked. When a new effect of this kind is applied, it replaces or
# refreshes the previous one.
const NON_STACKING_EFFECTS := ["haste", "slow", "reflect"]

# The two properties below work the same way as with the `ActiveTurnQueue`.
# The setters assign the value to child nodes.
var time_scale := 1.0: 
	set = set_time_scale
var is_active := true:
	set = set_is_active
	
func add(effect: StatusEffect) -> void:
	# Ensure the effect is not null
	if effect == null:
		push_error("Attempted to add a null status effect")
		return
	
	# Ensure the effect is not already a child of another node
	if effect.get_parent() != null:
		effect.get_parent().remove_child(effect)
		
	effect.name = effect.id
	
	# If we already have active effects, we may have to replace one.
	# If it can stack, we replace the one with the smallest time left.
	if effect.can_stack():
		if _has_maximum_stacks_of(effect.id):
			_remove_effect_expiring_the_soonest(effect.id)
	# If it's a unique effect like slow or haste, we replace it.
	elif has_node(NodePath(effect.name)):
		# We call `StatusEffect.expire()` to let the effect properly clean up itself.
		get_node(NodePath(effect.name)).expire()
	
	# The status effects are nodes so all we need to do is add it as a child of the container.
	add_child(effect)
	
	# emit signal after adding it
	emit_signal("status_effect_added", effect)
	print("status effect added ", effect)

# Removes all stacks of an effect of a given type.
func remove_type(id: String) -> void:
	for effect in get_children():
		if effect.id == id:
			effect.expire()


# Removes all status effects.
func remove_all() -> void:
	for effect in get_children():
		effect.expire()


# The two setters below are similar to what we did in `ActiveTurnQueue.gd`
func set_time_scale(value: float) -> void:
	time_scale = value
	for effect in get_children():
		effect.time_scale = time_scale


func set_is_active(value) -> void:
	is_active = value
	for effect in get_children():
		effect.is_active = is_active


# Returns `true` if there are `MAX_STACKS` instances of a given status effect.
func _has_maximum_stacks_of(id: String) -> bool:
	var count := 0
	for effect in get_children():
		if effect.id == id:
			count += 1
	return count == MAX_STACKS

func has(id: String) -> bool:
	for effect in get_children():
		if effect.id == id:
			return true
	return false


func get_active_effects() -> Array:
	var effects := []
	for child in get_children():
		if child is StatusEffect:
			effects.append(child)
	return effects


# Finds and expires the effect of a given type expiring the soonest.
func _remove_effect_expiring_the_soonest(id: String) -> void:
	var to_remove: StatusEffect
	var smallest_time: float = INF
	# We have to check all effects to find the ones that match the `id`.
	for effect in get_children():
		if effect.id != id:
			continue
		# We compare the `time_left` for an effect of type `id` to the current `smallest_time` and
		# if it's smaller, we update the variables.
		var time_left: float = effect.get_time_left()
		if time_left < smallest_time:
			to_remove = effect
			smallest_time = time_left
	to_remove.expire()
	
	# emit signal after removing effect
	emit_signal("status_effect_removed", to_remove)
