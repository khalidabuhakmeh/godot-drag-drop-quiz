extends Area2D
class_name Draggable

var mouse_offset = 0
var selected = false
@export var locked: bool = false:
	set(value):
		selected = true
		locked = true
	get:
		return locked

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if StateManager.is_playing and selected:
		var mouse_position = get_global_mouse_position()
		position = mouse_position + mouse_offset;
	if not StateManager.is_playing:
		reset(0)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if StateManager.is_playing and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and not locked:
			if StateManager.currently_dragging != null:
				StateManager.currently_dragging.reset(0)

			mouse_offset = position - get_global_mouse_position()
			z_index = 1000
			selected = true
			modulate.a = 0.5
			StateManager.currently_dragging = self
		else:
			reset(0)

func reset(new_zindex) -> void:
	selected = false
	modulate.a = 1
	z_index = new_zindex

func get_shape() -> Vector2:
	var shape = $CollisionShape2D.shape
	return shape.size
