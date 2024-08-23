class_name UIEffectBar
extends HBoxContainer

# preload the effect point
const UIEffectPoint: PackedScene  = preload("res://CombatSystem/UserInterface/UIBattlerHUD/UIEffectPoint.tscn")

var effect_points := {}

func setup(battler:Battler) -> void:
	clear_effect_points()
	# gets the active effects
	var active_status_effects = battler._status_effect_container.get_children()
	for i in active_status_effects:
		var effect_point: TextureRect = UIEffectPoint.instantiate()
		effect_point._fill = active_status_effects[i].icon
		add_child(effect_point)
		
	# Connect signals from the StatusEffectContainer
	battler._status_effect_container.status_effect_added.connect(_on_status_effect_added)
	battler._status_effect_container.status_effect_removed.connect(_on_status_effect_removed)

func clear_effect_points() -> void:
	for effect_point in effect_points.values():
		remove_child(effect_point)
	effect_points.clear()
	
func add_effect_point(effect: StatusEffect) -> void:
	var effect_point: TextureRect = UIEffectPoint.instantiate()
	effect_point.texture = effect._icon  # Assuming `StatusEffect` has an `icon` property
	effect_points[effect] = effect_point
	add_child(effect_point)

func remove_effect_point(effect: StatusEffect) -> void:
	if effect in effect_points:
		remove_child(effect_points[effect])
		effect_points.erase(effect)

func _on_status_effect_added(effect: StatusEffect) -> void:
	add_effect_point(effect)

func _on_status_effect_removed(effect: StatusEffect) -> void:
	remove_effect_point(effect)
