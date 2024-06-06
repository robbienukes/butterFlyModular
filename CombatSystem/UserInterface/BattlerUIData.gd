# Stores the properties required by UI widgets that represent this battler.
class_name BattlerUIData
extends Resource

# The battler's name to display, for example, in the HUD or in a menu.
@export var display_name := ""
# An icon representing the battler. We'll use it in the turn bar in lesson 4.
@export var texture: Texture
