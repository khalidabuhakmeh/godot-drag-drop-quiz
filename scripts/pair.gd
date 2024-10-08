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
	
	$Shortcut.position = StateManager.get_open_point()
	$Key.position = StateManager.get_open_point()

func lock_pair():
	StateManager.increment_score(shortcut_combo)
	var boom: CPUParticles2D = explosion.instantiate()
	add_child(boom)
	boom.position = get_viewport().get_mouse_position()
	boom.explode = true
	boom.z_index = 10
	$Key.visible = false
	$Shortcut.visible = false
	# destroy this pair
	boom.finished.connect(queue_free)
