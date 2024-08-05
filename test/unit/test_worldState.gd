extends 'res://addons/gut/test.gd'

var world_wrapper = load("res://CombatSystem/WorldWrapper.tscn")
var _world_wrapper = null;

func before_each():
	_world_wrapper = world_wrapper.instantiate()
	get_tree().root.add_child(_world_wrapper)
	
func after_each():
	_world_wrapper.free()	

func test_worldState():
	assert_eq(_world_wrapper.world_state, "EXISTS", "World State Exists")

func test_bran_readiness():
	var bran = _world_wrapper.get_node("CombatModule/ActiveTurnQueue/BRAN")
	assert_not_null(bran, "Bran should be instantiated and accessible")
	bran._set_readiness(100)
	assert_eq(bran._readiness, 100, "Bran's readiness should be 100")

func test_bran_action():
	var bran = _world_wrapper.get_node("CombatModule/ActiveTurnQueue/BRAN")
	bran._set_readiness(100)
	assert_eq(bran._readiness, 100, "Bran's readiness should be 100")
