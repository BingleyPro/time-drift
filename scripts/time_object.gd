extends Node

@export_group("Time Behaviour")
@export var propagate_past_changes: bool = false

@onready var past_node = $Past
@onready var present_node = $Present
@onready var future_node = $Future

func _ready () -> void:
	# Connect to the timeline_changed signal
	var time_manager = get_node("/root/TimeManager")
	time_manager.connect("timeline_changed", Callable(self, "on_timeline_changed"))
	
	# Make sure inital state matches current timeline
	_on_timeline_changed(time_manager.current_timeline)

func _on_timeline_changed(new_timeline) -> void:
	# Hide all layers first
	past_node.visible = false
	present_node.visible = false
	future_node.visible = false
	
	# Show only the relevant layer
	match new_timeline:
		"PAST":
			past_node.visible = true
		"PRESENT":
			present_node.visible = true
		"FUTURE":
			future_node.visible = true
