# Displays a party member's name, health, and energy.
class_name UIBattlerHUD
extends NinePatchRect

@onready var _health_counter := $HealthCounter
@onready var _energy_counter := $EnergyCounter
@onready var _effect_bar := $UIEffectBar
@onready var _label := $Label
@onready var _anim_player: AnimationPlayer = $AnimationPlayer

var battler: Battler


# Store a reference to the front anchor node


# Initializes the health and energy bars using the battler's stats.
func setup(battler: Battler) -> void:
	print("🧱 UIBattlerHUD setup:", battler.name)

	battler.selection_toggled.connect(_on_Battler_selection_toggled)

	_label.text = battler.ui_data.display_name
	
	var stats: BattlerStats = battler.stats
	# I had to change the order of the parameters here to match
	# `UIValueCounter.setup()`.
	_health_counter.setup(stats.health, stats.max_health)
	_energy_counter.setup(stats.energy, stats.max_energy)
	
	_effect_bar.setup(battler)

	stats.health_changed.connect(_on_BattlerStats_health_changed)
	stats.energy_changed.connect(_on_BattlerStats_energy_changed)
	modulate.a = 0.0


func _on_BattlerStats_health_changed(_old_value: float, new_value: float) -> void:
	_health_counter.target_value = new_value


# Here, also, instead of setting the `value` property, to trigger the animation,
# I used the `target_value` instead.
func _on_BattlerStats_energy_changed(_old_value: float, new_value: float) -> void:
	_energy_counter.target_value = new_value

#
func _on_Battler_selection_toggled(value: bool) -> void:
	if value:
		_anim_player.play("select")
	else:
		_anim_player.play("deselect")
		
func fade_in() -> void:
	if _anim_player.has_animation("fade_in"):
		_anim_player.play("fade_in")
	else:
		modulate.a = 1.0

func fade_out() -> void:
	if _anim_player.has_animation("fade_out"):
		_anim_player.play("fade_out")
	else:
		modulate.a = 0.0
	
