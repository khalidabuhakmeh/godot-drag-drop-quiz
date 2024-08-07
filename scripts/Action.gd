extends Node
class_name Action

@export var id: String = ""
@export var description: String = "";
@export var shortcuts: Array[ShortcutCombo];

# Called when the node enters the scene tree for the first time.
func _init(initial_id:String) -> void:
	self.id = initial_id

func print_debug() -> void:
	print("id: " + id + " ("+ description + ")")
	for shortcut in shortcuts:
		var key = shortcut.key
		var layout = shortcut.layout
		print("    key combo: " + key + " (" + layout + ")")
