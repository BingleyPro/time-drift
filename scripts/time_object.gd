extends Node

@export_group("Time Behaviour")
@export var propagate_past_changes: bool = false

@export_category("Timeline Settings")

@export var exists_in_past: bool = true
@export var exists_in_present: bool = true
@export var exists_in_future: bool = true

@export_group("Past Settings")
@export var broken_in_past: bool = false

@export_group("Present Settings")
@export var broken_in_present: bool = false

@export_group("Future Settings")
@export var broken_in_future: bool = false

@onready var past_node = $Past
@onready var present_node = $Present
@onready var future_node = $Future

func _ready () -> void:
	# Connect to the timeline_changed signal
	var time_manager = get_node("/root/TimeManager")
	time_manager.connect("timeline_changed", Callable(self, "_on_timeline_changed"))
	
	# TODO: Check exists_in_[timeline] and disable collision for anything else
	
	# Make sure inital state matches current timeline
	_on_timeline_changed(time_manager.current_timeline)

func _on_timeline_changed(new_timeline) -> void:
	print("Timeline changed to: ", new_timeline)
	# Hide all layers first
	past_node.visible = false
	present_node.visible = false
	future_node.visible = false
	
	# Show only the relevant layer
	match new_timeline:
		TimeManager.Timeline.PAST:
			if exists_in_past:
				past_node.visible = true
		TimeManager.Timeline.PRESENT:
			if exists_in_present:
				present_node.visible = true
		TimeManager.Timeline.FUTURE:
			if exists_in_future:
				future_node.visible = true
		_:
			print("Unknown timeline: ", new_timeline)
