extends Draggable

@export var target: Draggable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	if target.locked:
		follow()
	pass

func _on_area_entered(area: Area2D) -> void:
	if area == target:
		follow()
		target.locked = true;
		target.reset(100)
		StateManager.increment_score()
	pass # Replace with function body.

func follow() -> void:
	var shape = target.get_shape()
	target.position = position
	target.position.x -= shape.x
