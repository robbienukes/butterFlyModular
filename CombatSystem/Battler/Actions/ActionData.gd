class_name ActionData
extends Resource

# We will define this enum several times in our codebase.
# Having it in the file allows us to use it as an export hint and to have a
# drop-down menu in the inspector. See `element` below.
enum Elements { NONE, CODE, DESIGN, ART, BUG }
enum ActionTypes { PHYSICAL, MAGICAL, ITEM, CONDITION }


# The following two properties are for the user interface.
# We will use them to represent the action in menus.
@export var icon: Texture
@export var label := "Base combat action"
@export var is_heal: bool = false


# Set explicit action type
@export var action_type := ActionTypes.PHYSICAL
# Amount of energy the action costs to perform.
@export var energy_cost := 0
# Elemental type of the action. We'll use it later to add bonus damage if
# the action's target is weak to the element.
@export var element := Elements.NONE

# The following properties help us filter potential targets on a battler's turn.
@export var is_targeting_self := false
@export var is_targeting_all := false

# The amount of readiness left to the battler after acting.
# You can use it to design weak attacks that allow you to take turn fast.
@export var readiness_saved := 0.0

@export var power: int


# Returns `true` if the `battler` has enough energy to use the action.
func can_be_used_by(battler) -> bool:
	return energy_cost <= battler.stats.energy
