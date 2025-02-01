extends Node

@export_group("Time Behaviour")
@export var propagate_past_changes: bool = false

@export_category("Timeline Settings")

@export var exists_in_past: bool = true
@export var exists_in_present: bool = true
@export var exists_in_future: bool = true

enum Property { NORMAL, BROKEN }

@export_group("Past Settings")
@export var past_properties: Property

@export_group("Present Settings")
@export var present_properties: Property

@export_group("Future Settings")
@export var future_properties: Property

@onready var past_node = $Past
@onready var present_node = $Present
@onready var future_node = $Future

func _ready () -> void:
	# Connect to the timeline_changed signal
	var time_manager = get_node("/root/TimeManager")
	time_manager.connect("timeline_changed", Callable(self, "_on_timeline_changed"))
	
	if not exists_in_past:
		past_node.visible = false
		_disable_collisions(past_node)
		past_node.queue_free()
		
	if not exists_in_present:
		present_node.visible = false
		_disable_collisions(present_node)
		present_node.queue_free()
		
	if not exists_in_future:
		future_node.visible = false
		_disable_collisions(future_node)
		future_node.queue_free()
	
	# Make sure inital state matches current timeline
	_on_timeline_changed(time_manager.current_timeline)

func _on_timeline_changed(new_timeline) -> void:
	print("Timeline changed to: ", new_timeline)
	# Hide all layers first
	if exists_in_past:
		past_node.visible = false
	if exists_in_present:
		present_node.visible = false
	if exists_in_future:
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

func _disable_collisions(node: Node) -> void:
	for child in node.get_children():
		if child is CollisionShape3D:
			# Zero out layer and mask to prevent collision.
			child.disabled = true

		# Recursively disable collisions on children
		_disable_collisions(child)
