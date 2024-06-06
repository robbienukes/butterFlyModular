class_name Action
# Reference is the default type you extend in Godot, even if you omit this line.
# Godot allocates and frees instances of a Reference from memory for you.
extends Node

# Emitted when the action finished playing.
signal finished

var _data: ActionData
var _actor
var _targets := []


# The constructor allows you to create actions from code like so:
# var action := Action.new(data, battler, targets)
func _init(data: ActionData, actor, targets: Array) -> void:
	_data = data
	_actor = actor
	_targets = targets

func apply_async() -> bool:
	await Engine.get_main_loop().process_frame
	emit_signal("finished")
	return true
	
# Returns `true` if the action should target opponents by default.
func targets_opponents() -> bool:
	return true

# The battler needs to know how much readiness they should retain after 
# performing the action.
func get_readiness_saved() -> float:
	return _data.readiness_saved


# Exposing the energy cost will allow us to highlight energy points an action
# will use in the energy bar.
func get_energy_cost() -> int:
	return _data.energy_cost
