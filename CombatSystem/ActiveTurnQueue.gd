class_name ActiveTurnQueue
extends Node

signal player_turn_finished
signal ui_action_menu_reference_received(reference)

var is_active := true: set = set_is_active
var time_scale := 1.0: set = set_time_scale

var _party_members := []
var _opponents := []
var _is_player_playing := false
var _queue_player := []
var battlers := []

@export var UIActionMenuScene: PackedScene
@export var SelectArrow: PackedScene

func init(battler_array) -> void:
	battlers = battler_array
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

	print(battler, " Turn starting")
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

	print("Potential targets for battler ", battler.name, ": ", potential_targets)

	if battler.is_player_controlled():
		battler.is_selected = true
		set_time_scale(0.05)
		_is_player_playing = true

		var is_selection_complete := false
		while not is_selection_complete:
			action_data = await _player_select_action_async(battler)
			if action_data == null:
				push_error("Player did not select a valid action.")
				continue
			if action_data.is_targeting_self:
				targets = [battler]
			else:
				targets = await _player_select_targets_async(action_data, potential_targets)
				Events.player_target_selection_done.emit()
			is_selection_complete = action_data != null and targets != []
		set_time_scale(1.0)
		battler.is_selected = false
	else:
		action_data = battler.actions[0]
		targets = [potential_targets[0]]

	var action: Action = _create_action_from_data(action_data, battler, targets)
	add_child(action)  # ← this is mandatory!
	battler.act(action)
	await battler.action_finished

	if battler.is_player_controlled():
		player_turn_finished.emit()

func _player_select_action_async(battler: Battler) -> ActionData:
	var action_menu: UIActionMenu = UIActionMenuScene.instantiate()
	var target_node = get_parent().get_node("UI")
	if target_node:
		target_node.add_child(action_menu)
	else:
		add_child(action_menu)
	action_menu.open(battler)
	return await action_menu.action_selected

func _player_select_targets_async(_action: ActionData, opponents: Array) -> Array:
	var arrow: UISelectBattlerArrow = SelectArrow.instantiate()
	add_child(arrow)
	arrow.setup(opponents)
	var targets = await arrow.target_selected
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

func _create_action_from_data(action_data: ActionData, battler: Battler, targets: Array) -> Action:
	if action_data.label == "Revolver Shot" and action_data is AttackActionData:
		return RevolverAction.new(action_data, battler, targets)
	elif action_data is AttackActionData:
		var attack_data := action_data as AttackActionData
		if attack_data.action_script:
			print("🧠 Creating custom action from script:", attack_data.action_script)
			return attack_data.action_script.new(attack_data, battler, targets)
		else:
			print("📄 Using default AttackAction")
			return AttackAction.new(attack_data, battler, targets)
	else:
		push_error("❌ Unknown action type or invalid data: " + str(action_data))
		return AttackAction.new(AttackActionData.new(), battler, targets) # Fallback
