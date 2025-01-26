extends Node

@export var past_layer: Node3D
@export var present_layer: Node3D

# Track the current timeline that the player is in
var current_timeline = "present"

# Called when the node enters the scene tree for the first time.
#func _ready():
#	switch_to("present")
#	
func switch_timeline():
	if current_timeline == "present":
		switch_to("past")
	else:
		switch_to("present")
		
func switch_to(timeline):
	if timeline == "past":
		past_layer.visible = true
		present_layer.visible = false
		_set_collision_enabled(past_layer, true)
		_set_collision_enabled(present_layer, false)
		current_timeline = "past"
	else:
		past_layer.visible = false
		present_layer.visible = true
		_set_collision_enabled(past_layer, false)
		_set_collision_enabled(present_layer, true)
		current_timeline = "present"
		
func _set_collision_enabled(layer, enabled):
	for node in layer.get_children():
		if node is CollisionObject3D:
			node.set_deferred("disabled", !enabled)
