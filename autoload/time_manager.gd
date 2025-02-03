extends Node

enum Timeline { PAST, PRESENT, FUTURE }

signal timeline_changed(new_timeline)
signal timeline_selection_started
signal timeline_selection_canceled
signal timeline_selected(selected_timeline)

@export var num_timelines: int = 3
var _timeline_states = []
var _timeline_index = 0
var is_selecting_timeline: bool = false
var timeline_ui = null
var current_timeline = Timeline.PRESENT 

func _ready():
	# Generate timeline states
	for i in range(num_timelines):
		_timeline_states.append("Timeline " + str(i + 1))
	
	# Wait one frame for the current scene to be ready
	await get_tree().process_frame
	
	# Look in the current scene for TimelineUI
	if get_tree().current_scene:
		timeline_ui = get_tree().current_scene.get_node_or_null("TimelineUI")
		# If not found, instance timeline_ui.tscn and add it
		if timeline_ui == null:
			print("TimelineUI not found in scene. Instancing timeline_ui.tscn")
			var timeline_scene = load("res://scenes/timeline_ui.tscn")
			if timeline_scene:
				timeline_ui = timeline_scene.instance()
				get_tree().current_scene.add_child(timeline_ui)
			else:
				push_error("Could not load timeline_ui.tscn")
				
	if timeline_ui:
		timeline_ui.setup_timelines(_timeline_states)
	else:
		push_error("TimelineUI is not available even after instancing.")

func start_timeline_selection() -> void:
	is_selecting_timeline = true
	emit_signal("timeline_selection_started")
	if timeline_ui:
		timeline_ui.show_list()  # Show UI when selecting
	else:
		push_error("Cannot start selection, TimelineUI is null.")
	print("Timeline selection started.")

func cancel_timeline_selection() -> void:
	is_selecting_timeline = false
	emit_signal("timeline_selection_canceled")
	if timeline_ui:
		timeline_ui.hide_list()  # Hide UI when canceling
	else:
		push_error("Cannot cancel selection, TimelineUI is null.")
	print("Timeline selection canceled.")

func next_timeline() -> void:
	if is_selecting_timeline and timeline_ui:
		_timeline_index = (_timeline_index + 1) % _timeline_states.size()
		timeline_ui.update_highlight(_timeline_index)  # Update UI
		print("Switched to next timeline: ", _timeline_states[_timeline_index])

func previous_timeline() -> void:
	if is_selecting_timeline and timeline_ui:
		_timeline_index = (_timeline_index - 1 + _timeline_states.size()) % _timeline_states.size()
		timeline_ui.update_highlight(_timeline_index)  # Update UI
		print("Switched to previous timeline: ", _timeline_states[_timeline_index])

func select_current_timeline() -> void:
	if is_selecting_timeline and timeline_ui:
		is_selecting_timeline = false
		timeline_ui.hide_list()
		current_timeline = _timeline_index  # Update current_timeline
		emit_signal("timeline_selected", _timeline_states[_timeline_index])
		emit_signal("timeline_changed", current_timeline)  # Send enum value
		print("Current timeline selected and changed to: ", _timeline_states[_timeline_index])
