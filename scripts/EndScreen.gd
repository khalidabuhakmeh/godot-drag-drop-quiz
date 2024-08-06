extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	StateManager.round_start.connect(round_start)
	StateManager.round_finished.connect(round_finished)

func round_start() -> void:
	visible = false

func round_finished() -> void:
	$VBoxContainer/RichTextLabel.text = "[center][rainbow][wave]Final Score " + str(StateManager.score) + "!"
	var shortcut_display: RichTextLabel = $VBoxContainer/Shortcuts
	
	shortcut_display.text = "[center]"
	for combo: ActionShortcutCombo in StateManager.current_solved:
		shortcut_display.text += "- " + combo.description + " (" + combo.key + ")\n"
	
	var pieces = get_tree().get_nodes_in_group("pieces")
	for p in pieces:
		p.queue_free()
	visible = true
