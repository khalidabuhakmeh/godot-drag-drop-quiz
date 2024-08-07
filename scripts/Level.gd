extends Node
class_name Level

@export var level_name: String = "";
@export var include: String = "";
@export var actions: Array[Action];

# Called when the node enters the scene tree for the first time.
func _init(initial_level_name: String, initial_include: String) -> void:
	self.level_name = initial_level_name
	self.include = initial_include

func print_debug() -> void:
	print("level name: " + level_name)
	for action in actions:
		var id = action.id
		var description = action.description
		print("    action: " + id + " (" + description + ")")
