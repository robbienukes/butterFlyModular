extends Node2D

# Include the CombatModule script
const COMBAT_MODULE_PATH = "res://CombatSystem/CombatModule.tscn"

const BATTLE_ENTITIES = {
	"BRAN": preload("res://CombatSystem/Battler/Entities/Party/Bran.tscn"),
	"LILLEL": preload("res://CombatSystem/Battler/Entities/Party/Lillel.tscn"),
	"FIREDOG": preload("res://CombatSystem/Battler/Entities/Enemies/Firedog.tscn")
}

var world_state = "EXISTS"

func _ready():
	var battlers_array = []
	var battler_names = []
	
	# Populate arrays from the dictionary
	for name in BATTLE_ENTITIES.keys():
		battler_names.append(name)
		battlers_array.append(BATTLE_ENTITIES[name])
	
	var combat_module_scene = load(COMBAT_MODULE_PATH)
	var combat_module_instance = combat_module_scene.instantiate()
	add_child(combat_module_instance)
	combat_module_instance.init(battlers_array, battler_names)
