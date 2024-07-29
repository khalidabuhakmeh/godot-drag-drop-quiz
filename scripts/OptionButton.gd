extends OptionButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for layout in StateManager.layouts:
		add_item(layout.layout_name)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_item_selected(index: int) -> void:
	StateManager.current_layout = StateManager.layouts[index]
	var random_action = StateManager.get_random_action()
	
	random_action.print_debug()
	
	pass # Replace with function body.
