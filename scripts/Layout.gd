extends Resource 
class_name Layout 

@export var layout_name: String = ""
@export var platform: String = ""

func _init(initial_name: String, initial_platform: String) -> void:
	self.layout_name = initial_name
	self.platform = initial_platform

func print_debug() -> void:
	print("name: " + layout_name + ", platform: " + platform)
