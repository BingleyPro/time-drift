extends CanvasLayer

@onready var fps_label = $FPSLabel
@onready var sprint_bar = $SprintBar

func _ready():
	sprint_bar.max_value = 100
	sprint_bar.value = 100
	
func _process(_delta):
	# Update FPS counter
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
