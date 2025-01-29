extends Node

# All possible timelines
enum Timeline { PAST, PRESENT, FUTURE }

signal timeline_changed(new_timeline)
signal timeline_selection_started
signal timeline_selection_canceled
signal timeline_selected(selected_timeline)

@export var current_timeline: Timeline = Timeline.PRESENT

# List of timeline states in a cycle
var _timeline_states = [Timeline.PAST, Timeline.PRESENT, Timeline.FUTURE]
var _timeline_index = 1 # Start at PRESENT

var is_selecting_timeline: bool = false

func start_timeline_selection() -> void:
	# Start selecting a timeline
	is_selecting_timeline = true
	emit_signal("timeline_selection_started")
	print("Timeline selection started.")

func cancel_timeline_selection() -> void:
	# Cancel selecting a timeline
	is_selecting_timeline = false
	emit_signal("timeline_selection_canceled")
	print("Timeline selection canceled.")

func next_timeline() -> void:
	_timeline_index = (_timeline_index + 1) % _timeline_states.size()
	print("Switched to next timeline: ", _timeline_states[_timeline_index])

func previous_timeline() -> void:
	_timeline_index = (_timeline_index - 1 + _timeline_states.size()) % _timeline_states.size()
	print("Switched to previous timeline: ", _timeline_states[_timeline_index])

func select_current_timeline() -> void:
	current_timeline = _timeline_states[_timeline_index]
	is_selecting_timeline = false
	emit_signal("timeline_selected", current_timeline)
	emit_signal("timeline_changed", current_timeline)
	print("Current timeline selected and changed to: ", current_timeline)
