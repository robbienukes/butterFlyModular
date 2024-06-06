# Queues and delegates turns for all battlers.
class_name ActiveTurnQueue
extends Node

signal player_turn_finished

var is_active := true: set = set_is_active
var time_scale := 1.0: set = set_time_scale

var _party_members := []
var _opponents := []
var _is_player_playing := false
var _queue_player := []

@export var UIActionMenuScene: PackedScene

@export var SelectArrow: PackedScene

@onready var battlers := get_children()


func _ready() -> void:
	player_turn_finished.connect(_on_player_turn_finished)
	for battler in battlers:
		battler.setup(battlers)
		battler.ready_to_act.connect(_on_Battler_ready_to_act.bind(battler))
		if battler.is_party_member:
			_party_members.append(battler)
		else:
			_opponents.append(battler)

func set_is_active(value: bool) -> void:
	is_active = value
	for battler in battlers:
		battler.is_active = is_active

func set_time_scale(value: float) -> void:
	time_scale = value
	for battler in battlers:
		battler.time_scale = time_scale

func _play_turn(battler: Battler) -> void:
	var action_data: ActionData
	var targets := []

	battler.stats.energy += 1
	battler.is_selected = true

	var potential_targets := []
	var opponents := _opponents if battler.is_party_member else _party_members
	for opponent in opponents:
		if opponent.is_selectable:
			potential_targets.append(opponent)
	if battler.is_party_member:
		for party_member in _party_members:
			potential_targets.append(party_member)
	
	# Debug: Print potential targets
	print("Potential targets for battler ", battler.name, ": ", potential_targets)



	if battler.is_player_controlled():
		battler.is_selected = true
		set_time_scale(0.05)
		_is_player_playing = true

		var is_selection_complete := false
		while not is_selection_complete:
			action_data = await _player_select_action_async(battler)
			if action_data.is_targeting_self:
				targets = [battler]
			else:
				targets = await _player_select_targets_async(action_data, potential_targets)
				Events.player_target_selection_done.emit()
			is_selection_complete = action_data != null && targets != []
		set_time_scale(1.0)
		battler.is_selected = false
	else:
		action_data = battler.actions[0]
		targets = [potential_targets[0]]

	var action = AttackAction.new(action_data, battler, targets)
	battler.act(action)
	
	await battler.action_finished

	if battler.is_player_controlled():
		player_turn_finished.emit()



func _player_select_action_async(battler: Battler) -> ActionData:
	# Every time the player has to select an action in the turn loop, we instantiate the menu.
	var action_menu: UIActionMenu = UIActionMenuScene.instantiate()
	add_child(action_menu)
	# Calling its `open` method makes it appear and populates it with action buttons.
	action_menu.open(battler)
	# We then wait for the player to select an action in the menu and to return it.
	var data: ActionData = await action_menu.action_selected
	return data


func _player_select_targets_async(_action: ActionData, opponents: Array) -> Array:
# We instantiate the arrow, add it as a child, and call its `setup()` function.
	var arrow: UISelectBattlerArrow = SelectArrow.instantiate()
	add_child(arrow)
	arrow.setup(opponents)
	# We then wait for it to return a target, which means the player either selected a target
	# or cancelled the operation.
	var targets = await arrow.target_selected
	# If the player cancelled, the `_play_turn()` function's loop will reopen the action menu,
	# then create a new arrow.
	arrow.queue_free()
	return targets


func _on_Battler_ready_to_act(battler: Battler) -> void:
	if battler.is_player_controlled() and _is_player_playing:
		_queue_player.append(battler)
	else:
		_play_turn(battler)


func _on_player_turn_finished() -> void:
	if _queue_player.size() == 0:
		_is_player_playing = false
	else:
		_play_turn(_queue_player.pop_front())
