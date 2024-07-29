extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	StateManager.round_start.connect(round_start)
	StateManager.round_finished.connect(round_finished)

func round_start() -> void:
	visible = false

func round_finished() -> void:
	$VBoxContainer/RichTextLabel.text = "[center][rainbow][wave]Final Score " + str(StateManager.score) + "!"
	visible = true
