extends Node

@export var timeline_layers: Array[Node3D]
@export var player: CharacterBody3D

# Track the current timeline that the player is in
var current_timeline_index = 0

func _ready():
	if timeline_layers.is_empty():
		push_error("No timeline layers assigned!")
		return
		
	for layer in timeline_layers:
		if layer:
			layer.visible = false
			
	# Show the starting timeline
	switch_timeline(0)

func switch_timeline(index: int):
	if index < 0 or index >= timeline_layers.size():
		push_error("Invalid timeline index")
		return
		
	# Hide all other layers
	for i in range(timeline_layers.size()):
		timeline_layers[i].visible = (i == index)
		
	# Set player's collision mask to match the active timeline
	if index == 0:  # Present timeline
			player.collision_mask = 0b0001  # Binary for Layer 1
	if index == 1:  # Past timeline
			player.collision_mask = 0b0010  # Binary for Layer 2
	if index == 2:  # Present timeline
			player.collision_mask = 0b0011  # Binary for Layer 3
	if index == 3:  # Past timeline
			player.collision_mask = 0b0100  # Binary for Layer 4

	# highlight only the new timeline
	highlight_timeline(index)
	
	current_timeline_index = index

#func _input(event):
	#if event.is_action_pressed("switch_timeline"):
	#	var new_index = (current_timeline_index + 1) % timeline_layers.size()
	#	switch_timeline(new_index)

var selected_timeline = 0
var selecting = false

func start_timeline_selection():
	selecting = true
	selected_timeline = current_timeline_index
	highlight_timeline(selected_timeline)

func cancel_timeline_selection():
	selecting = false
	highlight_timeline(current_timeline_index)

func next_timeline():
	if not selecting:
		return
	selected_timeline = (selected_timeline + 1) % timeline_layers.size()
	highlight_timeline(selected_timeline)

func previous_timeline():
	if not selecting:
		return
	selected_timeline = (selected_timeline - 1 + timeline_layers.size()) % timeline_layers.size()
	highlight_timeline(selected_timeline)

func select_current_timeline():
	if not selecting:
		return
	switch_timeline(selected_timeline)
	change_scene(timeline_layers[selected_timeline])

func highlight_timeline(_index: int):
	for i in range(timeline_layers.size()):
		var layer = timeline_layers[i]

		_apply_highlight_to_node(layer, i == _index)

		layer.visible = (i == _index) or (selecting and i == selected_timeline)

func _apply_highlight_to_node(node: Node, highlight: bool) -> void:
	if node is MeshInstance3D:
		if node.material_override:
			var new_material = node.material_override.duplicate()
			if new_material.has_parameter("albedo_color"):
				var color = new_material.get("albedo_color")
				color.a = 0.5 if highlight else 1.0
				new_material.set("albedo_color", color)
			node.material_override = new_material
	for child in node.get_children():
		if child is Node:
			_apply_highlight_to_node(child, highlight)


func change_scene(timeline: Node3D):
	var scene_path = timeline.get("scene_path")
	if scene_path == null or scene_path == "":
		push_error("scene_path is null or empty.")
		return
	
	var new_scene = load(scene_path)
	if new_scene:
		get_tree().change_scene_to(new_scene)
	else:
		push_error("Could not load scene: " + str(scene_path) + " .")
