extends CharacterBody3D


const SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 5.0
const DOUBLE_JUMP_VELOCITY = 4.0
const MOUSE_SENSITIVITY = 0.003
var has_double_jamped = false
var gravity = ProjectSettings.get_setting('physics/3d/default_gravity')


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
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif not has_double_jamped:
			velocity.y = DOUBLE_JUMP_VELOCITY
			has_double_jamped = true

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("a", "d", "w", "s")
	var current_speed = SPEED
	if Input.is_key_pressed(KEY_SHIFT):
		current_speed = SPRINT_SPEED
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
