extends Resource
class_name ShortcutCombo

@export var layout_name: String = "";
@export var key: String = "";

func _init(initial_layout: String, initial_key: String) -> void:
	self.layout_name = initial_layout
	self.key = initial_key
