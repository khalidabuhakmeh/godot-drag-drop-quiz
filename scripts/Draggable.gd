extends Control
class_name Draggable

var dropped_on_target: bool = false
var target: Control

func _get_drag_data(at_position: Vector2) -> Variant:
	if not dropped_on_target:
		var control = _get_preview_control(at_position)
		set_drag_preview(control)
		return self
	else:
		return null

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if data != null and data.target == self and data == self.target:
		return true
	else:
		return false

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if data != null and data.target == self and data == self.target:
		dropped_on_target = true
		get_parent().lock_pair()

func _get_preview_control(at_position: Vector2) -> Control:
	var preview = Panel.new()
	var control = self.duplicate()
	control.position = Vector2(0, 0)
	preview.add_child(control)
	preview.size = size
	preview.modulate.a = .8
	self.modulate.a = 0.1
	preview.set_position(at_position)
	preview.set_rotation(.01)
	var show_control = func(): self.modulate.a = 1
	preview.tree_exited.connect(show_control)
	return preview
