extends Draggable 

@export var target: Draggable

@onready var collision_shape:CollisionShape2D = $CollisionShape2D
@onready var control: Control = $Panel/Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_shape.shape.extents = control.get_rect()
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
