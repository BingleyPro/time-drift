class_name PlayerCharacter
extends CharacterBody3D

enum Timeline { PAST, PRESENT, FUTURE }

enum CharacterState {
	WALKING = 0,
	SPRINTING = 1,
	CROUCHING = 2
}
var hud: Node = null

# All of the actually important stuff
@onready var head := $head
@onready var plrGUI := $PlayerGUI
@onready var InteractRaycast := $head/RayCast3D
@onready var camera := $head/Camera3D
@onready var animator := $AnimationPlayer
@onready var timeline_manager = get_node("/root/TimeManager")
var currentBody : Interactible3D = null
var currentState : CharacterState = CharacterState.WALKING
@onready var SPEED = DEFAULT_SPEED # DEFAULT_SPEED doesn't load until _ready(), so we have to use @onready (you could also just move SPEED a bit to the bottom)

var is_arm_up = false
var selecting_timeline = false

# Options
@export var DEFAULT_SPEED := 3
@export var JUMP_VELOCITY := 3
@export var mouse_sensitivity := 0.1
@export var SPRINT_SPEED := 3.5
@export var CROUCH_SPEED := 1.5
@export var MAX_STAMINA := 100.0
@export var SPRINT_DRAIN_RATE := 20.0
@export var REGEN_RATE := 5.0
@export var MIN_STAMINA_SPRINT := 0

var current_stamina := MAX_STAMINA # current stamina
var is_sprinting := false # is the player sprinting
var inputEnabled := true # can the player move?
var aimlookEnabled := true # can the player look around?
var interactionsEnabled := true # can the player interact with Interactibles3D?
var scroll_accumulation := 0.0
var SCROLL_THRESHOLD := 3

#region Main control flow 

func _ready():
	$MeshInstance3D.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	GameManager.player = self
	
	hud = get_parent().get_node("HUD")
	current_stamina = MAX_STAMINA
	
	if hud == null:
		push_error("HUD not found")
		
	timeline_manager.connect("timeline_changed", Callable(self, "update_player_collision"))

func _physics_process(delta: float) -> void:
	if !inputEnabled:
		return
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED) 
	
	# All of the other processing functions go here
	_process_interact()
	_handle_states()
	
	_update_stamina(delta)
	
	move_and_slide()

#endregion

#region Processing input

func _process_interact():
	if !interactionsEnabled:
		return
	if not InteractRaycast.is_colliding():
		plrGUI.update_text("")
		return
	var collider = InteractRaycast.get_collider()
	if not collider is Interactible3D:
		plrGUI.update_text("")
		return
	if collider == currentBody and not Input.is_action_just_pressed("interact"): # This is a bit hacky imo, but works
		plrGUI.update_text(currentBody.InteractText)
		return
	
	currentBody = collider
	plrGUI.update_text(currentBody.InteractText)
	if Input.is_action_just_pressed("interact") && currentBody.CanInteract:
		currentBody.OnInteract.emit()

# Handles the mouse 🐁🐁🐁🐁🐁🐁🐁🐁
func _unhandled_input(event : InputEvent):
	if !aimlookEnabled:
		return
	
	if event is InputEventMouseMotion:
		var mouseInput : Vector2
		mouseInput += event.relative
		self.rotation_degrees.y -= mouseInput.x * mouse_sensitivity
		head.rotation_degrees.x -= mouseInput.y * mouse_sensitivity
	
	if event is InputEventKey:
		if event.pressed and event.keycode == Key.KEY_T:
			# Toggle the "arm" animation and timeline selection
			if not is_arm_up:
				animator.play("arm")
				is_arm_up = true
				selecting_timeline = true
				timeline_manager.start_timeline_selection()
			else:
				animator.play_backwards("arm")
				is_arm_up = false
				selecting_timeline = false
				timeline_manager.cancel_timeline_selection()

	# Handle all types of scroll input when selecting timeline
	elif selecting_timeline:
		if event is InputEventMouseButton and event.pressed:
			match event.button_index:
				MOUSE_BUTTON_WHEEL_UP:
					scroll_accumulation -= 5.0
				MOUSE_BUTTON_WHEEL_DOWN:
					scroll_accumulation += 5.0
				MOUSE_BUTTON_LEFT:
					timeline_manager.select_current_timeline()
					animator.play_backwards("arm")
					is_arm_up = false
					selecting_timeline = false
					scroll_accumulation = 0
		
		# Handle trackpad gestures
		elif event is InputEventPanGesture:
			scroll_accumulation += event.delta.y * 100.0
			print("Pan Gesture detected:", event.delta.y, "Accumulation:", scroll_accumulation)
		
		elif event is InputEventMouseMotion and event.relative.y != 0:
			if Input.is_physical_key_pressed(Key.KEY_ALT):
				scroll_accumulation += event.relative.y * 0.5
		
		if abs(scroll_accumulation) >= SCROLL_THRESHOLD:
			if scroll_accumulation > 0:
				timeline_manager.next_timeline()
			else:
				timeline_manager.previous_timeline()
			scroll_accumulation = 0

#endregion

#region Processing Character States

## Handles the input for character state changing. 
func _handle_states():
	if Input.is_action_just_pressed("crouch"):
		if currentState == CharacterState.CROUCHING:
			change_state(CharacterState.WALKING)
		else:
			change_state(CharacterState.CROUCHING)
	elif Input.is_action_pressed("sprint"):
		if currentState == CharacterState.CROUCHING:
			return
		if currentState == CharacterState.SPRINTING:
			return
		# Only start sprinting if we have enough stamina
		if current_stamina > MIN_STAMINA_SPRINT + 5.0: # Add buffer
			is_sprinting = true
			change_state(CharacterState.SPRINTING)
	else:
		if currentState == CharacterState.SPRINTING:
			is_sprinting = false
		if currentState != CharacterState.WALKING and currentState != CharacterState.CROUCHING:
			change_state(CharacterState.WALKING)

## Handles the state changing itself. This function must be fired only once, and not run every single frame. 
func change_state(state : CharacterState):
	match state:
		CharacterState.CROUCHING:
			animator.play("crouch")
			SPEED = CROUCH_SPEED
		CharacterState.SPRINTING:
			SPEED = SPRINT_SPEED
			animator.play("sprint")
		CharacterState.WALKING:
			if currentState == CharacterState.CROUCHING:
				animator.play_backwards("crouch")
			elif currentState == CharacterState.SPRINTING:
				animator.play_backwards("sprint")
			SPEED = DEFAULT_SPEED
	
	currentState = state

#endregion

func _update_stamina(delta: float) -> void:
	if is_sprinting:
		# Drain stamina while sprinting
		current_stamina -= SPRINT_DRAIN_RATE * delta
		if current_stamina <= MIN_STAMINA_SPRINT + 2.0:
			current_stamina = MIN_STAMINA_SPRINT
			is_sprinting = false
			change_state(CharacterState.WALKING)  # Stop sprinting when stamina runs out
	else:
		# Regenerate stamina when not sprinting
		if current_stamina < MAX_STAMINA:
			current_stamina += REGEN_RATE * delta
			current_stamina = min(current_stamina, MAX_STAMINA)
		
	# Update HUD progress bar
	if hud:
		var stamina_bar = hud.get_node("SprintBar")
		if stamina_bar:
			stamina_bar.value = current_stamina

# TIME TRAVEL
#func _process(delta):
#	if Input.is_action_just_pressed("switch_timeline"):
#		var new_index = (current_timeline_index + 1) % timeline_layers.size()
#		switch_timeline(new_index)

func update_player_collision(timeline_enum) -> void:
	var new_mask = 0
	
	match timeline_enum:
		Timeline.PAST: # Past
			new_mask = 1
		Timeline.PRESENT: # Present
			new_mask = 2
		Timeline.FUTURE: # Future
			new_mask = 4
			
	self.collision_mask = new_mask
