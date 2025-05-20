# Menu displaying lists of actions the player can select.
class_name UIActionMenu
extends Control

# Emitted when the player selected an action.
signal action_selected

# We preload our UIActionList scene to instantiate it from the code.
# The file UIActionList.tscn must be in the same directory for this to work.
const UIActionList := preload("UIActionList.tscn")
const UIActionButton: PackedScene = preload("UIActionButton.tscn")

var current_battler: Battler
var last_focused_button: TextureButton = null
var active_submenu: Node = null


func _ready() -> void:
	hide()


# This function is a bit like the previous nodes' `setup()`, but I decided to call it open
# instead because it feels more natural for a menu. Also, it toggles the node's visibility on.
func open(battler: Battler) -> void:
	current_battler = battler  # 🔁 Store for later
	_populate_category_buttons(battler)

	show()
	# Focus first category button manually here if needed

# We free the menu upon closing it.
func close() -> void:
	hide()
	if active_submenu:
		active_submenu.queue_free()
		active_submenu = null
	queue_free()



func _on_UIActionsList_action_selected(action: ActionData) -> void:
	emit_signal("action_selected", action)
	close()
	
func _populate_category_buttons(battler: Battler) -> void:
	print("🧪 RootSelectArrow exists?", is_instance_valid($RootSelectArrow))

	$RootSelectArrow.visible = true

	for child in $MainListContainer.get_children():
		child.queue_free()
	
	var categories = ActionData.ActionTypes.values()
	var buttons := []
	var labels := []

	for category in categories:
		var button = UIActionButton.instantiate()
		var has_actions := battler.actions.any(func(a): return a.action_type == category)

		# Use ActionData to reuse setup method
		var dummy_action := ActionData.new()
		dummy_action.label = ActionData.ActionTypes.keys()[category].capitalize()
		dummy_action.icon = null  # Optionally set an icon per category

		button.setup(dummy_action, has_actions)
		button.pressed.connect(_on_category_button_pressed.bind(category))
		button.focus_entered.connect(_on_category_button_focused.bind(button))

		$MainListContainer.add_child(button)
		buttons.append(button)
		labels.append(dummy_action.label)

	
	# Focus the first usable button and move the arrow
	for button in buttons:
		if not button.disabled:
			await get_tree().process_frame  # Wait for layout
			button.grab_focus()
			$RootSelectArrow.visible = true  # ✅ Make sure it's visible
			var rect = button.get_global_rect()
			$RootSelectArrow.global_position = rect.position + Vector2(0.0, rect.size.y / 2.0)
			break


func _on_category_button_pressed(category: int) -> void:
	last_focused_button = get_viewport().gui_get_focus_owner()
	# Disable/hide root
	$MainListContainer.visible = false
	$RootSelectArrow.hide()

	if active_submenu:
		active_submenu.queue_free()

	active_submenu = UIActionList.instantiate()
	add_child(active_submenu)
	active_submenu.setup(current_battler, category)
	active_submenu.back_selected.connect(_on_submenu_back)
	active_submenu.action_selected.connect(_on_UIActionsList_action_selected)
	active_submenu.focus()

func _on_category_button_focused(button: TextureButton) -> void:
	if not is_instance_valid($RootSelectArrow):
		push_warning("⚠️ RootSelectArrow is not valid.")
		return

	var rect = button.get_global_rect()
	$RootSelectArrow.global_position = rect.position + Vector2(0.0, rect.size.y / 2.0)
	$RootSelectArrow.visible = true  # ✅ Always re-show when focus moves

	

func _on_submenu_back() -> void:
	if active_submenu:
		active_submenu.queue_free()
		active_submenu = null

	$MainListContainer.visible = true
	$RootSelectArrow.visible = true

	if is_instance_valid(last_focused_button):
		await get_tree().process_frame  # ⚠ ensure layout is valid again
		last_focused_button.grab_focus()
		_on_category_button_focused(last_focused_button)  # 🟢 reposition arrow
	else:
		print("⚠️ last_focused_button was invalid — falling back to first available.")
		# Optional fallback to first button:
		for child in $MainListContainer.get_children():
			if child is TextureButton and not child.disabled:
				child.grab_focus()
				_on_category_button_focused(child)
				break


