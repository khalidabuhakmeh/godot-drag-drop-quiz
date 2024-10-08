extends Node

signal score_changed(score: int)
signal time_changed(time: String)
signal round_finished()
signal round_start()
signal layout_changed(layout:Layout)
signal level_changed(level:Level)

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
@export var levels: Array[Level];
@export var selected_layout: Layout:
	set(value):
		layout_changed.emit(value)
		selected_layout = value

@export var selected_level: Level:
	set(value):
		level_changed.emit(value)
		selected_level = value

var current_solved: Array[ActionShortcutCombo]

var previously_selected_keys: Array[String]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	manage_points_on_grid()
	process_keymaps()
	process_levels()
	selected_layout = layouts[0] # set to $default
	selected_level = levels[0]
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

func get_random_level_action() -> ActionShortcutCombo:
	
	var filter_level_by_level_name = func(s: Level) -> bool:
		return s.level_name == selected_level.level_name
	
	var filter_shortcut_by_layout = func(s: ShortcutCombo) -> bool:
		return s.layout_name == selected_layout.layout_name
	
	var filter_actions_by_layout = func(s: Action) -> bool:
		return s.shortcuts.any(filter_shortcut_by_layout)
	
	var level = levels.filter(filter_level_by_level_name)[0]
	var level_actions = level.actions
	if (level.include != ""):
		var filter_level_by_included_level_name = func(s: Level):
			return s.level_name == level.include
		
		var included_level = levels.filter(filter_level_by_included_level_name)[0]
		level_actions.append_array(included_level.actions)
	
	var pick_one = func() -> ActionShortcutCombo:
		var action_in_layout = level_actions.filter(filter_actions_by_layout).pick_random()
		var shortcut_in_layout = action_in_layout.shortcuts.filter(filter_shortcut_by_layout).pick_random()
		return ActionShortcutCombo.new(action_in_layout, shortcut_in_layout)
	
	var result: ActionShortcutCombo = pick_one.call()
	var is_unique = previously_selected_keys.find(result.key) == -1
	while !is_unique:
		result = pick_one.call()
		is_unique = previously_selected_keys.find(result.key) == -1

	previously_selected_keys.push_back(result.key)
	return result

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
	manage_points_on_grid()
	previously_selected_keys.clear()
	current_solved.clear()
	time_left = round_time
	is_playing = true
	score = 0
	round_start.emit()

func get_open_point() -> Vector2:
	var is_available := func(p: Node):
		var filled = p.get_meta("filled", false)
		return filled != null and filled == false
		
	var point: Node = get_tree().get_nodes_in_group("grid_points").filter(is_available).pick_random()
	point.set_meta("filled", true)
	return point.global_position

func manage_points_on_grid() -> void:
	var points = get_tree().get_nodes_in_group("grid_points") 	
	if points.size() > 0:
		for point in points :
			point.set_meta("filled", false)
	else:
		var grid_container: Area2D = get_tree().get_first_node_in_group("grid_container")
		var collision_shape = grid_container.get_node("CollisionShape2D")
		var css = collision_shape.shape
		var viewport = css.size
		var start_pos_x = 350
		var start_pos_y = 300
		var element_size = Vector2(350, 120)
		
		var number_on_x_axis = floori(viewport.x / element_size.x)
		var number_on_y_axis = floori(viewport.y / element_size.y)
		
		for x in number_on_x_axis:
			for y in number_on_y_axis:
				var point = Node2D.new()
				var position_x = start_pos_x + (x * element_size.x)
				var position_y = start_pos_y + (y * element_size.y)
				point.global_position = Vector2(position_x, position_y)
				point.set_meta("filled", false)
				point.add_to_group("grid_points")
				grid_container.add_child(point)
