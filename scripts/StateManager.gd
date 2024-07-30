extends Node

signal score_changed(score: int)
signal time_changed(time: String)
signal round_finished()
signal round_start()

const POINTS = 100

@export var currently_dragging: Draggable
@export var round_time = 61
@export var is_playing = true
@export var total_pairs = 5

var time_left;
var previous_time;

@export var score = 0:
	set(value):
		score = value
		score_changed.emit(score)
	get:
		return score

@export var layouts: Array[Layout];
@export var actions: Array[Action];
@export var current_layout: Layout:
	set(value):
		layout_changed.emit(value)
		current_layout = value

signal layout_changed(layout:Layout);

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_keymaps()
	current_layout = layouts[0] # set to $default	
	var random = get_random_action()	
	random.print_debug()
	time_left = round_time
	round_start.emit()
	
func _process(delta) -> void:
	if is_playing:
		if (time_left > 0):
			time_left -= delta
			tick()
		else:
			is_playing = false
			round_finished.emit()

func process_keymaps() -> void:
	var parser = XMLParser.new()
	parser.open("res://keymap.xml")
	var current_action: Action
	while parser.read() != ERR_FILE_EOF:
		var node_type = parser.get_node_type()
		if node_type == XMLParser.NODE_ELEMENT:
			var node_name = parser.get_node_name()
			# get the layouts
			if (node_name == "layout"):
				var layout = Layout.new(parser.get_named_attribute_value("name"), parser.get_named_attribute_value("platform"))
				layouts.push_back(layout)
			if (node_name == "action"):
				# only push actions have shortcuts
				if (current_action != null and !current_action.shortcuts.is_empty()):
					actions.push_back(current_action)
				current_action = Action.new(parser.get_named_attribute_value("id"))
			if (node_name == "description"):
				# move to NODE_TEXT
				parser.read()
				var description = parser.get_node_data()
				current_action.description = description
			if (node_name == "shortcut"):
				var layout = parser.get_named_attribute_value("layout")
				# move to NODE_TEXT
				parser.read()
				var keys = parser.get_node_data()
				current_action.shortcuts.push_back(ShortcutCombo.new(layout, keys))

func get_random_action() -> ActionShortcutCombo:
	
	var filter_shortcut_by_layout = func(s:ShortcutCombo):
		return s.layout_name == current_layout.layout_name
	
	var filter_actions_by_layout = func(s:Action):
		return s.shortcuts.any(filter_shortcut_by_layout)
	
	var action_in_layout = actions.filter(filter_actions_by_layout).pick_random()
	var shorcut_in_layout = action_in_layout.shortcuts.filter(filter_shortcut_by_layout).pick_random()
	return ActionShortcutCombo.new(action_in_layout, shorcut_in_layout)
	
func increment_score() -> void:
	score += POINTS;
	var total_points_possible = total_pairs * POINTS;
	if (score == total_points_possible):
		is_playing = false
		score += int(time_left * POINTS)
		round_finished.emit()

func _format_seconds(time : float) -> String:
	var minutes := time / 60
	var seconds := fmod(time, 60)

	return "%02d:%02d" % [minutes, seconds]

func tick() -> void:
	var time = _format_seconds(time_left)	
	if (previous_time != time):
		previous_time = time
		time_changed.emit(time)
		
func reset() -> void:
	round_start.emit()
	is_playing = true
	score = 0
	time_left = round_time
