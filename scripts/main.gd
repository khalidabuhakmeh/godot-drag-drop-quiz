extends Node2D

@onready var options: OptionButton = $CanvasLayer/MarginContainer/HFlowContainer/KeymapContainer/OptionButton
@onready var score_label: Label = $CanvasLayer/MarginContainer/HFlowContainer/ScoreContainer/Value
@onready var countdown_label: Label = $CanvasLayer/MarginContainer/HFlowContainer/CountdownContainer/Value
@onready var end_screen = $CanvasLayer/EndScreen
@onready var play_field = $CanvasLayer

@export_range(1, 10) var total_pairs := 5:
	get: 
		return StateManager.total_pairs
	set(value):
		StateManager.total_pairs = value
		
@export var round_time = 61:
	get:
		return StateManager.round_time
	set(value):
		StateManager.round_time = value

var pair_scene = preload("res://scenes/pair.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	
	for layout in StateManager.layouts:
		options.add_item(layout.layout_name)
	
	StateManager.current_layout = StateManager.layouts[options.selected]
	StateManager.score_changed.connect(update_score)
	StateManager.time_changed.connect(update_timer)
	StateManager.reset()
	
	randomize_shortcuts()

	pass # Replace with function body.

func update_score(score: int) -> void:
	score_label.text = str(score)
	
func update_timer(time: String) -> void:
	countdown_label.text = time

func randomize_shortcuts() -> void:
	var window_size = $Camera2D.get_viewport_rect().size
	var pieces = get_tree().get_nodes_in_group("pieces")
	
	# clear the current pieces
	for piece in pieces:
		piece.queue_free()
	
	for i in total_pairs:
		var instance = pair_scene.instantiate()
		# review: need to make sure the combos are unique
		instance.shortcut_combo = StateManager.get_random_level_action(StateManager.current_level_name)
		instance.set_random_position(window_size)
		instance.add_to_group("pieces")
		play_field.add_child(instance)

func _on_option_button_item_selected(index: int) -> void:
	StateManager.current_layout = StateManager.layouts[index]
	StateManager.reset()
	randomize_shortcuts()
	end_screen.visible = false

func _on_button_pressed() -> void:
	_on_option_button_item_selected(options.selected)
