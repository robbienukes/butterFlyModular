extends TextureRect


@onready var _label: Label = $Label
@onready var _fill: TextureRect = $Fill

# This function will be used to update the label
func set_count(count: int) -> void:
	if count > 1:
		_label.text = str(count)
	else:
		_label.text = ""  # Clear the label if count is 1 or less
