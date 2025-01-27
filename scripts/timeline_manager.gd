extends Node

@export var past_layer: Node3D
@export var present_layer: Node3D

@export var timeline_layers: Array[Node3D]
#@export var initial_position: Vector3 = Vector3.ZERO
@export var player: CharacterBody3D

# Track the current timeline that the player is in
var current_timeline_index = 0

func _ready():
	if timeline_layers.is_empty():
		push_error("No timeline layers assigned!")
		return
		
	# Align all layers to the same position at runtime
	for layer in timeline_layers:
		if layer:
			#layer.global_transform.origin = initial_position
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
			player.collision_mask = 0b0001  # Binary for Layer 1 (Present)
	if index == 1:  # Past timeline
			player.collision_mask = 0b0010  # Binary for Layer 2 (Past)
	
	current_timeline_index = index

func _input(event):
	if event.is_action_pressed("switch_timeline"):
		var new_index = (current_timeline_index + 1) % timeline_layers.size()
		switch_timeline(new_index)
