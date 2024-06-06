# Represents one energy point. This node has two animations and functions to make it appear and disappear smoothly.
extends TextureRect

const POSITION_SELECTED := Vector2(0.0, -6.0)

@onready var _fill: TextureRect = $Fill
@onready var _color_transparent := _fill.modulate


func appear() -> void:
	var _tween = get_tree().create_tween()
	_tween.tween_property(_fill, "modulate", Color.WHITE, 0.3)


func disappear() -> void:
	var _tween = get_tree().create_tween()
	_tween.tween_property(_fill, "modulate", _color_transparent, 0.3)


func select() -> void:
	var _tween = get_tree().create_tween()
	_tween.tween_property(_fill,"position", POSITION_SELECTED, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func deselect() -> void:
	var _tween = get_tree().create_tween()
	_tween.tween_property(_fill, "position", Vector2.ZERO, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

