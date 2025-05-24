class_name Types
extends Node

# Element definitions — must match the enum in ActionData.gd
enum Elements { NONE, RAGE, SERENITY, ISOLATION, CHAOS, PRIDE, WILL, LIGHT, CONDITION }

# Weakness mappings — define which elements are strong against which
const WEAKNESS_MAPPING: Dictionary = {
	Elements.NONE: -1,
	Elements.RAGE: Elements.ISOLATION,
	Elements.SERENITY: Elements.RAGE,
	Elements.ISOLATION: Elements.PRIDE,
	Elements.CHAOS: Elements.SERENITY,
	Elements.PRIDE: Elements.WILL,
	Elements.WILL: Elements.CHAOS,
	Elements.LIGHT: Elements.CONDITION,
	Elements.CONDITION: Elements.LIGHT,
}

# Enum-to-string map for element lookup, UI, and reaction logic
const ELEMENT_NAMES: Dictionary = {
	Elements.NONE: "none",
	Elements.RAGE: "rage",
	Elements.SERENITY: "serenity",
	Elements.ISOLATION: "isolation",
	Elements.CHAOS: "chaos",
	Elements.PRIDE: "pride",
	Elements.WILL: "will",
	Elements.LIGHT: "light",
	Elements.CONDITION: "condition",
}
