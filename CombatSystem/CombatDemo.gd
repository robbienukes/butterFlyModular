extends Node2D

@onready var active_turn_queue := $ActiveTurnQueue
@onready var ui_turn_bar := $UI/UITurnBar
@onready var ui_battler_hud_list := $UI/UIBattlerHUDList
@onready var ui_damage_label_builder := $UI/UIDamageLabelBuilder
@onready var ui_canvas_layer := $UI


signal combat_ended(message)

enum CombatResult { DEFEAT, VICTORY }

var battlers := []

var names := []

# Function to initialize the CombatModule with the battlers array
func init(battlers_array, battler_names):
	battlers = battlers_array
	names = battler_names
	print("Battlers array received:", battlers)
	# Call the setup function after initializing the battlers array
	setup_combat()
	# For testing
	var test_combatModule_init = true


# Function to set up the combat
func setup_combat() -> void:
	print("Setting up combat")
	
	# Instantiate and add each battler to the active_turn_queue
	for i in range(battlers.size()):
		var packed_scene = battlers[i]
		if packed_scene is PackedScene:
			var battler_instance = packed_scene.instantiate()
			battler_instance.name = names[i]
			if battler_instance:
				print("Battler instantiated:", battler_instance)
				active_turn_queue.add_child(battler_instance)
			else:
				print("Failed to instantiate battler:", packed_scene)
		else:
			print("Invalid PackedScene in battlers array:", packed_scene)

	# Debug: print the children of active_turn_queue
	print("Active turn queue children:", active_turn_queue.get_children())
	
	var battler_nodes := active_turn_queue.get_children()
	
	# initialize battler nodes
	active_turn_queue.init(battler_nodes)
	
	# set up positions on screen
	var in_party := []
	var not_in_party := []
	
	var initial_position_party = Vector2(750, 250) # Starting position
	var initial_position_not_in_party = Vector2(200, 250) # Starting position
	var position_offset = Vector2(0, 250) # Offset between battlers		
	
	# crate parties
	for battler_instance in active_turn_queue.get_children():
		if battler_instance.is_party_member:
			in_party.append(battler_instance)
		else:
			not_in_party.append(battler_instance)
			
	for j in range(in_party.size()):
		var party_battler = in_party[j]
		if party_battler:
			party_battler.position = initial_position_party + position_offset * j
	
	for k in range(not_in_party.size()):
		var not_in_party_battler = not_in_party[k]
		if not_in_party_battler:
			not_in_party_battler.position = initial_position_not_in_party + position_offset * k
	
	ui_turn_bar.setup(active_turn_queue.get_children())
	ui_battler_hud_list.setup(in_party)

	for battler_instance in active_turn_queue.get_children():
		battler_instance.stats.health_depleted.connect(_on_BattlerStats_health_depleted.bind(battler_instance))
	
	ui_damage_label_builder.setup(active_turn_queue.get_children())



# We set up the turn bar when the node is ready, which ensures all its children also are ready.
func _ready() -> void:
	print("CombatDemo _ready called")
	# The setup_combat function will be called from init now
	if battlers.size() > 0:
		setup_combat()

# Returns an array of `Battler` who are in the same team as `actor`, including `actor`.
func get_ally_battlers_of(actor) -> Array:
	var team := []
	var active_turn_queue_children := active_turn_queue.get_children().filter(
		func(child) -> bool:
			return child is Battler
			)

	for battler in active_turn_queue_children:
		if battler.is_party_member == actor.is_party_member:
			team.append(battler)
	return team

# Returns `true` if all battlers in the array are fallen.
func are_all_fallen(battlers: Array) -> bool:
	var fallen_count := 0
	for battler in battlers:
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
	var team = get_ally_battlers_of(actor)
	if are_all_fallen(team):
		end_combat(CombatResult.DEFEAT if actor.is_party_member else CombatResult.VICTORY)
