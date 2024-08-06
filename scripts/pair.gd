extends Node2D

@onready var shortcut_label = $Shortcut/VBoxContainer/MarginContainer/Label
@onready var key_label = $Key/VBoxContainer/MarginContainer/Label
@onready var explosion = load("res://scenes/explosion.tscn")

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
	
	$Shortcut.target = $Key
	$Key.target = $Shortcut

func set_random_position(area: Vector2) -> void:
	var width = 300
	var height = 100
	
	var random_point = func() -> Vector2: 
		return Vector2(randi_range(width, area.x - width), randi_range(height, area.y - height))

	# Assign the new random position
	$Shortcut.position = random_point.call()
	$Key.position = random_point.call()
	
func lock_pair():
	StateManager.increment_score(shortcut_combo)
	var boom: CPUParticles2D = explosion.instantiate()
	add_child(boom)
	boom.position = get_viewport().get_mouse_position()
	boom.emitting = true
	boom.z_index = 10
	$Key.visible = false
	$Shortcut.visible = false
	# destroy this pair
	boom.finished.connect(queue_free)
