extends CanvasLayer

# We preload the `UICombatResultPanel` scene.
const UICombatResultPanel: PackedScene = preload("res://CombatSystem/UserInterface/UICombatResultPanel.tscn")

func _on_combat_demo_combat_ended(message):
	var widget: Control = UICombatResultPanel.instantiate()
	widget.text = message
	add_child(widget)
