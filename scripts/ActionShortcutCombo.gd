extends Resource
class_name ActionShortcutCombo

@export var key:String = "";
@export var id:String = "";
@export var layout_name:String = "";
@export var description: String = ""; 

func _init(action: Action, shortcut: ShortcutCombo) -> void:
	id = action.id
	key = shortcut.key
	layout_name = shortcut.layout_name
	description = action.description
	
func print_debug() -> void:
	print("id : " + id + " key: " + key + " description: " + description + " layout: " + layout_name)
