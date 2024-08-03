# Displays a list of UIBattlerHUDs, one for each battler in the party.
extends VBoxContainer

# We see the same pattern once again: preloading a UI widget and instancing it from the "list" component.
const UIBattlerHUD: PackedScene = preload("UIBattlerHUD.tscn")

@onready var _anim_player: AnimationPlayer = $AnimationPlayer


# Creates a battler HUD for each battler in the party.
func setup(battlers_array) -> void:
	print("Setting up UIBattlerHUDList with battlers:", battlers_array)
	for battler in battlers_array:
		var battler_hud: UIBattlerHUD = UIBattlerHUD.instantiate()
		add_child(battler_hud)
		battler_hud.setup(battler)


# The two functions below respectively play the fade in and fade out animations.
func fade_in() -> void:
	_anim_player.play("fade_in")


func fade_out() -> void:
	_anim_player.play("fade_out")
