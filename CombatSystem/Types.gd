# Using `class_name` allows us to access the constants from any other file.
class_name Types
extends Node

# This is the same enum we wrote in the ActionData classes.
enum Elements { NONE, LITERAL, ESOTERIC, SYMBOLIC, CONTRADICTION }

# Mapping between an element and the element against which it's strong.
const WEAKNESS_MAPPING: Dictionary = {
	# A value of -1 makes the element strong or weak against nothing.
	Elements.NONE: -1,
	# For example, the line below means that ESOTERIC is strong against LITERAL.
	Elements.ESOTERIC: Elements.LITERAL,
	Elements.LITERAL: Elements.SYMBOLIC,
	Elements.SYMBOLIC: Elements.ESOTERIC,
	Elements.CONTRADICTION: -1,
}
