extends Node

# All possible timelines
enum Timeline { PAST, PRESENT, FUTURE }

signal timeline_changed(new_timeline)

@export var current_timeline: Timeline = Timeline.PRESENT

# List of timeline states in a cycle
var _timeline_states = [Timeline.PAST, Timeline.PRESENT, Timeline.FUTURE]
var _timeline_index = 1 # Start at PRESENT

# TODO: move to player later
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_timeline"):
		switch_timeline()
		
func switch_timeline() -> void:
	# Cycle to the next timeline
	_timeline_index = (_timeline_index + 1) % _timeline_states.size()
	current_timeline = _timeline_states[_timeline_index]
	emit_signal("timeline_changed", current_timeline)
