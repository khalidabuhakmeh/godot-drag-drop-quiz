extends Node2D

@onready var shortcut_label: Label = $Shortcut/Panel/VBoxContainer/Label
@onready var key_label: Label = $Key/Panel/VBoxContainer/Label

@export var shortcut_combo: ActionShortcutCombo:
	set(value):
		shortcut_combo = value
	get:
		return shortcut_combo

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if (shortcut_combo == null):
		shortcut_combo = StateManager.get_random_action()
	
	key_label.text = shortcut_combo.key
	shortcut_label.text = shortcut_combo.description
	$Key.target = $Shortcut
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func set_random_position(area: Vector2) -> void:
	
	var width = 300
	var height = 100
	
	var random_point = func() -> Vector2: 
		return Vector2(randi_range(width, area.x - width), randi_range(height, area.y - height))

	# Assign the new random position
	$Shortcut.position = random_point.call()
	$Key.position = random_point.call()
