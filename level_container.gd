extends Node2D

@export var levels: Array[PackedScene] = []
var current_level_index := 0
@onready var level_root := $LevelRoot

func _ready() -> void:
	load_current_level()


func load_current_level() -> void:
	# Remove old children from level_root
	level_root.get_children().map(func(child): child.queue_free())

	if current_level_index >= levels.size():
		push_error("No more levels!")
		return
	
	var instance = levels[current_level_index].instantiate()
	level_root.add_child(instance)
	print("✅ Loaded level:", instance.name)

func next_level():
	current_level_index += 1
	load_current_level()
