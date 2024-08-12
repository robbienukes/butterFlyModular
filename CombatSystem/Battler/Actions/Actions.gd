class_name Action
extends Node

# Emitted when the action finished playing.
signal finished

var _data: ActionData
var _actor
var _targets := []
var is_reflected: bool = false # tracks if the action has been reflected


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
	
	# Add this method to the Action class if it doesn't exist
func set_targets(new_targets: Array) -> void:
	_targets = new_targets

# Inside your Action class
func set_actor(new_actor) -> void:
	_actor = new_actor
