# Spawns labels that display damage, healing, or missed hits.
class_name UIDamageLabelBuilder
extends Node2D

# We preload the labels.
@export var damage_label_scene: PackedScene = preload("res://CombatSystem/UserInterface/UIDamageLabel.tscn")
@export var miss_label_scene: PackedScene = preload("res://CombatSystem/UserInterface/UIMissedLabel.tscn")


# In setup(), we connect to the Battler's `damage_taken` and `hit_missed` signals to instantiate the appropriate labels.
func setup(battlers: Array) -> void:
	for battler in battlers:
		battler.damage_taken.connect(_on_Battler_damage_taken.bind(battler))
		battler.hit_missed.connect(_on_Battler_hit_missed.bind(battler))

func _on_Battler_damage_taken(amount: int, target: Battler) -> void:
	var label: UIDamageLabel = damage_label_scene.instantiate()

	var is_zombie : bool = target.has_status_effect("zombie")

	var label_type = UIDamageLabel.Types.DAMAGE
	if amount < 0 and not is_zombie:
		label_type = UIDamageLabel.Types.HEAL
	else:
		label_type = UIDamageLabel.Types.DAMAGE  # includes zombie healing-as-damage

	print("💥 Showing damage label for", target.name, "amount:", amount, "label type:", label_type)

	label.setup(label_type, target.battler_anim.get_top_anchor_global_position(), amount)
	add_child(label)

func _on_Battler_hit_missed(target: Battler) -> void:
	var label = miss_label_scene.instantiate()
	add_child(label)
	# The miss label doesn't have a setup() function so we set its position by hand.
	label.global_position = target.battler_anim.get_top_anchor_global_position()
