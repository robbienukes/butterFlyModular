extends 'res://addons/gut/test.gd'

var world_wrapper = preload("res://CombatSystem/WorldWrapper.tscn")
var _world_wrapper = null

func before_each():
	_world_wrapper = world_wrapper.instantiate()
	get_tree().root.add_child(_world_wrapper)


func after_each():
	_world_wrapper.queue_free()

func test_bran_action():
	var bran = _world_wrapper.get_node("CombatModule/ActiveTurnQueue/BRAN")
	var reflect_data = preload("res://CombatSystem/StatusEffects/reflect_effect.tres")
	
	# Ensure bran and its status effect container are valid
	assert_not_null(bran, "Bran should not be null")
	assert_not_null(bran._status_effect_container, "Bran's status effect container should not be null")
	
	# Create and add the reflect effect
	var reflect_effect = StatusEffectBuilder.create_status_effect(bran, reflect_data)
	bran._status_effect_container.add(reflect_effect)
	
	# Check if the reflect effect was added correctly
	var found_effect = false
	for child in bran._status_effect_container.get_children():
		print("Checking child:", child.name)  # Debug print
		if child.name == "reflect":  # Adjust the property name if needed
			found_effect = true
			break
	
	# Assert that the reflect effect has been added correctly
	assert_true(found_effect, "Reflect effect should be added to the container")
