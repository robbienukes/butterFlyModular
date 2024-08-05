extends Node2D

# Include the CombatModule script
const COMBAT_MODULE_PATH = "res://CombatSystem/CombatModule.tscn"

const BRAN = preload("res://CombatSystem/Battler/Entities/Party/Bran.tscn")
const LILLEL = preload("res://CombatSystem/Battler/Entities/Party/Lillel.tscn")
const FIREDOG = preload("res://CombatSystem/Battler/Entities/Enemies/Firedog.tscn")

# Define your array of battlers
var battlers_array = [BRAN, LILLEL, FIREDOG]

# TEST - Worls State exists
var world_state = "EXISTS"

func _ready():
	# Load the CombatModule scene
	var combat_module_scene = load(COMBAT_MODULE_PATH)
	# Instantiate the CombatModule scene
	var combat_module_instance = combat_module_scene.instantiate()
	# Add it as a child of WorldWrapper
	add_child(combat_module_instance)
	# Pass the battlers array to the CombatModule script
	combat_module_instance.init(battlers_array)
	
	

