extends Node

enum State {
	PAST,
	PRESENT,
	FUTURE
}

@export var current_state: int = State.PRESENT
@onready var world_objects = get_children()

func _ready():
	update_state(current_state)
	
func update_state(state: int):
	for obj in world_objects:
		if obj.get_script() and obj.has_method("update_state"): # update this later
			obj.update_state(state)

func _input(event):
	if event.is_action_pressed("switch_to_past"):
		update_state(State.PAST)
	elif event.is_action_pressed("switch_to_present"):
		update_state(State.PRESENT)
	elif event.is_action_pressed("switch_to_future"):
		update_state(State.FUTURE)
