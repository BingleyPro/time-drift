extends Control

var timeline_labels = []

func _ready():
	hide() # Start hidden

func setup_timelines(timelines: Array) -> void:
	# Clear existing labels
	for label in timeline_labels:
		label.queue_free()
	timeline_labels.clear()
	
	# Create new labels
	for i in range(timelines.size()):
		var label = Label.new()
		label.text = timelines[i]
		$VBoxContainer.add_child(label)
		timeline_labels.append(label)

func show_list() -> void:
	show()

func hide_list() -> void:
	hide()

func update_highlight(index: int) -> void:
	for i in range(timeline_labels.size()):
		var label = timeline_labels[i]
		label.modulate = Color.WHITE if i != index else Color.YELLOW
