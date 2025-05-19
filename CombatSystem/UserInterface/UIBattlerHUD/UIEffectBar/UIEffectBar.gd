extends HBoxContainer

# Preload the effect point
const UIEffectPoint: PackedScene = preload("res://CombatSystem/UserInterface/UIBattlerHUD/UIEffectBar/UIEffectPoint.tscn")

var effect_points := {}  # Dictionary to store effect points and their counts

func setup(battler: Battler) -> void:
	clear_effect_points()
	var active_status_effects = battler._status_effect_container.get_children()
	for effect in active_status_effects:
		add_effect_point(effect)
		
	# Connect signals from the StatusEffectContainer
	battler._status_effect_container.status_effect_added.connect(_on_status_effect_added)
	battler._status_effect_container.status_effect_removed.connect(_on_status_effect_removed)

func clear_effect_points() -> void:
	for effect_data in effect_points.values():
		remove_child(effect_data["node"])
	effect_points.clear()
	
func add_effect_point(effect: StatusEffect) -> void:
	var effect_id = effect.id  # Use a unique identifier for the effect

	if effect_id in effect_points:
		# Effect already exists, just increment the count and update the label
		if effect.can_stack():
			effect_points[effect_id]["count"] += 1
			_update_effect_label(effect_id)
	else:
		# Create a new effect point
		var effect_point: TextureRect = UIEffectPoint.instantiate()
		
		# Access the 'Fill' node safely
		var fill: TextureRect = effect_point.get_node("Fill")
		if fill:
			fill.texture = effect._icon  # Assuming `StatusEffect` has an `icon` property
		else:
			print("Error: 'Fill' node not found in effect point")

		# Store the effect point and initialize the count
		effect_points[effect_id] = {"node": effect_point, "count": 1}
		add_child(effect_point)
		
		# Update the label for the newly created effect point
		_update_effect_label(effect_id)

func remove_effect_point(effect: StatusEffect) -> void:
	var effect_id = effect.get_class()

	if effect_id in effect_points:
		if effect_points[effect_id]["count"] > 1:
			# If more than one of the effect is applied, decrement the count
			effect_points[effect_id]["count"] -= 1
			_update_effect_label(effect_id)
		else:
			# If it's the last effect, remove the effect point entirely
			remove_child(effect_points[effect_id]["node"])
			effect_points.erase(effect_id)

func _update_effect_label(effect_id: String) -> void:
	var effect_point = effect_points[effect_id]["node"]
	var count = effect_points[effect_id]["count"]
	
	# Ensure we are correctly accessing the label node
	var label: Label = effect_point.get_node("Label")
	
	if label == null:
		print("Label node not found within effect_point!")
		return
		
	
	if count > 1:
		label.text = str(count)
		print("Updated label for", effect_id, "to:", count)
	else:
		label.text = ""  # Clear the label if only one effect is applied
		print("Cleared label text for", effect_id)

func _on_status_effect_added(effect: StatusEffect) -> void:
	add_effect_point(effect)

func _on_status_effect_removed(effect: StatusEffect) -> void:
	remove_effect_point(effect)
