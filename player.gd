extends CharacterBody3D


const SPEED = 4.0
const SPRINT_SPEED = 10.0
const JUMP_VELOCITY = 5.0
const DOUBLE_JUMP_VELOCITY = 4.0
const MOUSE_SENSITIVITY = 0.003
var has_double_jamped = false
var jump_buffer_time = 0.2
var jump_buffer_timer = 0.0
var sprint_delay = 0.15
var sprint_timer = 0.0
var gravity = ProjectSettings.get_setting('physics/3d/default_gravity')
var hp = 100
@onready var health_bar: ProgressBar = $CanvasLayer/ProgressBar


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		$Camera3D.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		$Camera3D.rotation.x = clamp($Camera3D.rotation.x, deg_to_rad(-89), deg_to_rad(89))


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if is_on_floor():
		has_double_jamped = false
		if velocity.y < 0:
			velocity.y = 0
	else:
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer_timer = jump_buffer_time
		if jump_buffer_time > 0:
			jump_buffer_timer -= delta
		if is_on_floor() and jump_buffer_timer > 0:
			velocity.y = JUMP_VELOCITY
			jump_buffer_timer = 0
		elif Input.is_action_just_pressed("ui_accept") and not has_double_jamped:
			velocity.y = DOUBLE_JUMP_VELOCITY
			has_double_jamped = true

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("a", "d", "w", "s")
	var current_speed = SPEED
	if Input.is_key_pressed(KEY_SHIFT):
		sprint_timer += delta
		if sprint_timer >= sprint_delay:
			current_speed = SPRINT_SPEED
	else:
		sprint_timer = 0
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		attack()

func attack():
	var bodies = $Camera3D/hitbox.get_overlapping_bodies()
	for body in bodies:
		if body == self:
			continue
		if body.has_method('take_damage'):
			body.take_damage(1)
func take_damage(amount):
	hp = hp - amount
	var bar = get_node_or_null("CanvasLayer/ProgressBar")
	if bar:
		bar.value = hp
	if hp <= 0:
		die()

func die():
	get_tree().reload_current_scene()
