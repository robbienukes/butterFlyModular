# List of UIActionButton the player can press to select an action.
extends VBoxContainer

# Emitted when the player presses an action button.
signal action_selected(action)

# We instantiate an action button for each action on the battler. See the setup() function below.
# The file UIActionButton.tscn must be in the same directory for this to work.
const UIActionButton: PackedScene = preload("UIActionButton.tscn")


# Toggles all children buttons disabled.
# You can use this to implement nested action lists, freezing this one while the user browses another.
var _is_disabled: bool = false

var is_disabled: bool:
	get:
		return _is_disabled
	set(value):
		_is_disabled = value
		for button in buttons:
			button.disabled = value



# Among the node's children, there's the `UIMenuSelectArrow`, which isn't a button.
# We use this array to access and process the buttons efficiently.
var buttons := []

@onready var _select_arrow := $UIMenuSelectArrow


# To call from a parent node. Creates action buttons based on the battler's actions.
func setup(battler: Battler) -> void:
	# Below, action is of type ActionData.
	for action in battler.actions:
		# This is why this node takes the battler as an argument: we use it to check if the battler
		# can use the action when creating the menu.
		var can_use_action: bool = battler.stats.energy >= action.energy_cost
		# Instantiates a button and calls its `setup()` function.
		var action_button = UIActionButton.instantiate()
		add_child(action_button)
		action_button.setup(action, can_use_action)
		# Here, we start using binds with the signal callbacks. For each button,
		# we bind the current `action` to its "pressed" signal.
		action_button.pressed.connect(Callable(self, "_on_UIActionButton_button_pressed").bind(action))

		# We rely on the focus system of Godot's UI framework to know when the player
		# navigates between buttons.
		# We bind the button to retrieve its position from the callback function and move the arrow to it.
		action_button.focus_entered.connect(
	Callable(self, "_on_UIActionButton_focus_entered").bind(action_button, battler.ui_data.display_name, action.energy_cost)
)
		buttons.append(action_button)

	var button_rect = buttons[0].get_global_rect()
	_select_arrow.position = button_rect.position + Vector2(0.0, button_rect.size.y / 2.0)




# The list itself being a VBoxContainer, it can't grab focus.
# Instead of focusing the list itself, we want its first button to grab focus.
func focus() -> void:
	buttons[0].grab_focus()


# Disabling the list disables all buttons.
func set_is_disabled(value: bool) -> void:
	is_disabled = value
	for button in buttons:
		button.disabled = is_disabled


# When a button was pressed, it means the player selected an action, which we emit with the
# "action_selected" signal.
func _on_UIActionButton_button_pressed(action: ActionData) -> void:
	set_is_disabled(true)
	emit_signal("action_selected", action)
	
func _on_UIActionButton_focus_entered(button: TextureButton, battler_display_name: String, energy_cost: int) -> void:
	var button_rect = button.get_global_rect()
	_select_arrow.move_to(button_rect.position + Vector2(0.0, button_rect.size.y / 2.0))
