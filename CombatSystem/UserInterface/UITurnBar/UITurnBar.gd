# Timeline representing the turn order of all battlers in the arena.
# Battler icons move along the timeline as their readiness updates.
extends Control

# You can preload scenes with relative paths when they're in the same directory. The line below will
# work as long as `UIBattlerIcon.tscn` is in the same directory as `UITurnBar.gd`.
# When there's only one scene meant to be instanced by another, I like to preload it like that
# instead of using an `export var`.
const BattlerIcon := preload("res://CombatSystem/UserInterface/UIActionMenu/UIBattlerIcon.tscn")

#@onready var _background: TextureRect = $Background
@onready var _anim_player: AnimationPlayer = $AnimationPlayer

@onready var _line: ColorRect = $ColorRect

func _ready() -> void:
	# If _line is null, it means $ColorRect wasn't found, so create it programmatically.
	if _line == null:
		_line = ColorRect.new()
		add_child(_line)

	# Set the ColorRect properties
	_line.color = Color.WHITE

	# Set the size and position manually
	#_line.anchor_left = 0   # Resetting anchors to avoid confusion
	#_line.anchor_right = 0
	#_line.anchor_top = 0
	#_line.anchor_bottom = 0

	_line.size = Vector2(800, 50)  # Set the width to 80% of the screen width manually
	_line.position = Vector2(150, 100)      # Set position to 10% from the top, adjust as necessary

	#print("Line position: ", _line.position, ", Line size: ", _line.size)


# To initialize the turn bar, we pass all the battlers we want to display.
func setup(battlers: Array) -> void:
	for battler in battlers:
		# We first calculate the right icon background using the `Types` enum from `UIBattlerIcon`.
		# Below, I'm using the ternary operator. It picks the first value if the condition is `true`,
		# otherwise, it picks the second value.
		var type: int = (
			UIBattlerIcon.Types.PLAYER
			if battler.is_party_member
			else UIBattlerIcon.Types.ENEMY
		)
		# We create an instance of the `UIBattlerIcon` scene using a function and add it as a child.
		var icon: UIBattlerIcon = create_icon(type, battler.ui_data.texture)
		# We get to use the `Battler.readiness_changed` signal again to move the icons along the turn bar.
		# Once again, we bind the icon to the callback for each battler, so we don't have to worry
		# about which battler corresponds to which icon later.
		battler.connect("readiness_changed", Callable(self, "_on_Battler_readiness_changed").bind(icon))
		_line.add_child(icon)
		
func create_icon(type: int, texture: Texture) -> UIBattlerIcon:
	var icon: UIBattlerIcon = BattlerIcon.instantiate()
	icon.icon = texture
	icon.type = type

	# Calculate the position range based on the line's size and position
	var leftmost_point = _line.position.x
	var rightmost_point = _line.position.x + _line.size.x

	icon.position_range = Vector2(leftmost_point, rightmost_point)

	#print("left point ", leftmost_point, " right point: ", rightmost_point)

	return icon




 #The following two functions encapsulate animation playback and the animation player.
func fade_in() -> void:
	_anim_player.play("fade_in")


func fade_out() -> void:
	_anim_player.play("fade_out")


# This is where we update the position of each icon. Every time a battler emits the
# "readiness_changed" signal, we use this value to snap the corresponding icon to a new location.
func _on_Battler_readiness_changed(readiness: float, icon: UIBattlerIcon) -> void:
	# We call the `UIBattlerIcon.snap()` function we defined previously. I recommend using a
	# function or dedicated property here because polishing the game, you might want to animate the
	# icon's movement.
	icon.snap(readiness / 100.0)
