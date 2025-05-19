# Displays a list of UIBattlerHUDs, one for each battler in the party.
extends Control

# We see the same pattern once again: preloading a UI widget and instancing it from the "list" component.
const UIBattlerHUD: PackedScene = preload("res://CombatSystem/UserInterface/UIBattlerHUD/UIBattlerHUD.tscn")


@onready var _anim_player: AnimationPlayer = $AnimationPlayer
var y_offset := 0

var huds := {}

func setup(battlers_array: Array) -> void:
	print("Setting up UIBattlerHUDList with battlers:", battlers_array)
	
	# Clear old HUDs if needed
	for child in get_children():
		if child != _anim_player:
			child.queue_free
	huds.clear()

	# Stack HUDs vertically without using global positions
	var y_offset := 0
	for battler in battlers_array:
		var hud := UIBattlerHUD.instantiate()
		add_child(hud)
		hud.setup(battler)
		hud.position = Vector2(0, y_offset)
		y_offset += 90  # space between HUDs
		
		huds[battler] = hud
		hud.modulate.a = 0.0  # hide all initially

	# Optionally play fade in
	if _anim_player.has_animation("fade_in"):
		_anim_player.stop()
		_anim_player.play("fade_in")
	
func show_hud_for(battler: Battler) -> void:
	if battler in huds:
		huds[battler].fade_in()

func hide_all_huds() -> void:
	for hud in huds.values():
		hud.fade_out()



# The two functions below respectively play the fade in and fade out animations.
func fade_in() -> void:
	print("🟢 Skipping animation — forcing visible")
	visible = true
	modulate.a = 1.0


func fade_out() -> void:
	if _anim_player.has_animation("fade_out"):
		print("🎞️ Playing fade_out")
		_anim_player.stop()
		_anim_player.play("fade_out")
	else:
		print("⚠️ No fade_out animation found")
