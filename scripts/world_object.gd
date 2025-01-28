extends Node3D

enum State {
	PAST,
	PRESENT,
	FUTURE
}

@onready var past_state_node = $"Past State"
@onready var present_state_node = $"Present State"
@onready var future_state_node = $"Future State"

var past_children
var present_children
var future_children

func _ready():
	past_children = past_state_node.find_children("*", "", true, false)
	present_children = present_state_node.find_children("*", "", true, false)
	future_children = future_state_node.find_children("*", "", true, false)

func update_state(new_state: int):
	match new_state:
		State.PAST:
			set_current_state(past_children, true)
			set_current_state(present_children, false)
			set_current_state(future_children, false)
		State.PRESENT:
			set_current_state(past_children, false)
			set_current_state(present_children, true)
			set_current_state(future_children, false)
		State.FUTURE:
			set_current_state(past_children, false)
			set_current_state(present_children, false)
			set_current_state(future_children, true)
						
						
func set_current_state(objects: Array, enable: bool):
	for child in objects:
		if child is CollisionShape3D:
			child.disabled = not enable  # Enable/disable collision
		elif child is Node3D:
			child.visible = enable  # Enable/disable visibility for 3D objects
