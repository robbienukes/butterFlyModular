class_name  CombatDemo
extends Node2D

# We're going to get the battlers from the `ActiveTurnQueue` node.
@onready var active_turn_queue := $ActiveTurnQueue
@onready var ui_turn_bar := $UI/UITurnBar
@onready var ui_battler_hud_list := $UI/UIBattlerHUDList
@onready var ui_damage_label_builder := $UI/UIDamageLabelBuilder
signal combat_ended(message)


# This enum represents the two possible combat results.
enum CombatResult { DEFEAT, VICTORY }

# We set up the turn bar when the node is ready, which ensures all its children also are ready.
func _ready() -> void:
	var battlers: Array = active_turn_queue.battlers
	
	var in_party := []
	for battler in battlers:
		if battler.is_party_member:
			in_party.append(battler)
	
	ui_turn_bar.setup(active_turn_queue.battlers)
	ui_battler_hud_list.setup(in_party)
	
	for battler in battlers:
		battler.stats.health_depleted.connect(_on_BattlerStats_health_depleted.bind(battler))
	
	ui_damage_label_builder.setup(battlers)

# Returns an array of `Battler` who are in the same team as `actor`, including `actor`.
func get_ally_battlers_of(actor) -> Array:
	var team := []
	# We loop over all battlers on the battlefield.
	for battler in active_turn_queue.battlers:
		# If a battler's in the same party as `actor`, we append it to the array.
		if battler.is_party_member == actor.is_party_member:
			team.append(battler)
	return team


# Returns `true` if all battlers in the array are fallen.
func are_all_fallen(battlers: Array) -> bool:
	# We just count the fallen battlers!
	var fallen_count := 0
	for battler in battlers:
		# We reuse the `is_fallen()` method we already used with the `BattlerAI`.
		if battler.is_fallen():
			fallen_count += 1
	return fallen_count == battlers.size()

# Stops the turn queue, fades out the UI, and emits the `combat_ended` signal
func end_combat(result: int) -> void:
	active_turn_queue.is_active = false
	ui_turn_bar.fade_out()
	ui_battler_hud_list.fade_out()

	var message := "Victory" if result == CombatResult.VICTORY else "Defeat"
	combat_ended.emit(message)

# Every time a battler falls, we get their allies and check if they're all down too.
func _on_BattlerStats_health_depleted(actor) -> void:
	# We make those checks using the two functions we just created.
	var team := get_ally_battlers_of(actor)
	if are_all_fallen(team):
		# And if all fell, we emit the `combat_ended` signal.
		end_combat(CombatResult.DEFEAT if actor.is_party_member else CombatResult.VICTORY)
