class_name Types
extends Node

# Element definitions — must match the enum in ActionData.gd
enum Elements { NONE, FIRE, WATER, ICE, LIGHTNING, WIND, EARTH, HOLY, DARK }

# Weakness mappings — define which elements are strong against which
const WEAKNESS_MAPPING: Dictionary = {
	Elements.NONE: -1,
	Elements.FIRE: Elements.ICE,
	Elements.WATER: Elements.FIRE,
	Elements.ICE: Elements.WIND,
	Elements.LIGHTNING: Elements.WATER,
	Elements.WIND: Elements.EARTH,
	Elements.EARTH: Elements.LIGHTNING,
	Elements.HOLY: Elements.DARK,
	Elements.DARK: Elements.HOLY,
}

# Enum-to-string map for element lookup, UI, and reaction logic
const ELEMENT_NAMES: Dictionary = {
	Elements.NONE: "none",
	Elements.FIRE: "fire",
	Elements.WATER: "water",
	Elements.ICE: "ice",
	Elements.LIGHTNING: "lightning",
	Elements.WIND: "wind",
	Elements.EARTH: "earth",
	Elements.HOLY: "holy",
	Elements.DARK: "dark",
}
