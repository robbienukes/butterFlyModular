extends 'res://addons/gut/test.gd'

var world_wrapper = load("res://CombatSystem/WorldWrapper.tscn")
var _world_wrapper = null;

func before_each():
		# Load the CombatModule scene
	# Instantiate the CombatModule scene
	_world_wrapper = world_wrapper.instantiate()
	# Add it as a child of WorldWrapper
	
func after_each():
	_world_wrapper.free()	

func test_worldState():
	assert_eq(_world_wrapper.world_state, "EXISTS", "World State Exists")

func test_attack_made():
	assert_eq(_world_wrapper.world_state, "EXISTS", "World State Exists")
