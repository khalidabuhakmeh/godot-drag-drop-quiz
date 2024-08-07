extends Node

signal score_changed(score: int)
signal time_changed(time: String)
signal round_finished()
signal round_start()

const POINTS = 100

@export var current_level_name = "Medium" # todo: make selectable

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
@export var levels: Array[Level];
@export var current_layout: Layout:
	set(value):
		layout_changed.emit(value)
		current_layout = value
		
var current_solved: Array[ActionShortcutCombo]

signal layout_changed(layout:Layout);

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_keymaps()
	process_levels()
	current_layout = layouts[0] # set to $default	
	var random = get_random_level_action(current_level_name)	
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
	# push last action
	if (current_action != null and !current_action.shortcuts.is_empty()):
		actions.push_back(current_action)

func process_levels() -> void:
	var parser = XMLParser.new()
	parser.open("res://levels.xml")
	var current_level: Level
	var current_action: Action
	while parser.read() != ERR_FILE_EOF:
		var node_type = parser.get_node_type()
		if node_type == XMLParser.NODE_ELEMENT:
			var node_name = parser.get_node_name()
			# get the level
			if (node_name == "level"):
				current_level = Level.new(parser.get_named_attribute_value("name"), parser.get_named_attribute_value_safe("include"))
				levels.push_back(current_level)
			# get the actions
			if (node_name == "action"):
				# only push actions have shortcuts
				if (current_action != null and !current_action.shortcuts.is_empty()):
					current_level.actions.push_back(current_action)
				# get a known action by id
				var id = parser.get_named_attribute_value("id")
				if (id == "*"):
					# copy all actions
					for action in actions:
						if (!action.shortcuts.is_empty()):
							current_level.actions.push_back(duplicate_action(action))
					current_action = null
				else:
					# copy specific action
					var filter_actions_by_id = func(a: Action):
						return a.id == id
					
					var filtered_actions = actions.filter(filter_actions_by_id)
					if (filtered_actions.size() > 0):
						current_action = duplicate_action(filtered_actions[0])
					else:
						current_action = null
			# override action description if present
			if (node_name == "description" and current_action != null):
				# move to NODE_TEXT
				parser.read()
				var description = parser.get_node_data()
				current_action.description = description
			# override action shortcut if present
			if (node_name == "shortcut" and current_action != null):
				# move to NODE_TEXT
				parser.read()
				var keys = parser.get_node_data()
				
				# for now, override in all layouts
				for layout in layouts:
					current_action.shortcuts.push_back(ShortcutCombo.new(layout.layout_name, keys))
	# push last action
	if (current_level != null and current_action != null and !current_action.shortcuts.is_empty()):
		current_level.actions.push_back(current_action)

func duplicate_action(current_action: Action) -> Action:
	# rebuilding a copy of the action here so we can make further modifications later on
	# note: .duplicate() does not work to clone a Node
	var new_action = Action.new(current_action.id)
	new_action.description = current_action.description
	for combo in current_action.shortcuts:
		new_action.shortcuts.push_back(ShortcutCombo.new(combo.layout_name, combo.key))
	
	return new_action

func get_random_level_action(level_name: String) -> ActionShortcutCombo:
	
	var filter_level_by_level_name = func(s: Level):
		return s.level_name == level_name
	
	var filter_shortcut_by_layout = func(s: ShortcutCombo):
		return s.layout_name == current_layout.layout_name
	
	var filter_actions_by_layout = func(s: Action):
		return s.shortcuts.any(filter_shortcut_by_layout)
	
	var level = levels.filter(filter_level_by_level_name)[0]
	var level_actions = level.actions
	if (level.include != ""):
		var filter_level_by_included_level_name = func(s: Level):
			return s.level_name == level.include
		
		var included_level = levels.filter(filter_level_by_included_level_name)[0]
		level_actions.append_array(included_level.actions)
	
	var action_in_layout = level_actions.filter(filter_actions_by_layout).pick_random()
	var shorcut_in_layout = action_in_layout.shortcuts.filter(filter_shortcut_by_layout).pick_random()
	return ActionShortcutCombo.new(action_in_layout, shorcut_in_layout)
	
func increment_score(shortcut_combo: ActionShortcutCombo) -> void:
	score += POINTS;
	var total_points_possible = total_pairs * POINTS;
	current_solved.push_back(shortcut_combo)
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
	current_solved.clear()
	is_playing = true
	score = 0
	time_left = round_time
