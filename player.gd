extends CharacterBody3D


const SPEED = 4.0
const SPRINT_SPEED = 10.0
const JUMP_VELOCITY = 5.0
const DOUBLE_JUMP_VELOCITY = 5.0
const MOUSE_SENSITIVITY = 0.003
const HOOK_SPEED = 25.0
var has_double_jamped = false
var jump_buffer_time = 0.2
var jump_buffer_timer = 0.0
var acceleration_smoothness = 10.0
var current_dynamic_speed = 5.0
var gravity = ProjectSettings.get_setting('physics/3d/default_gravity')
var hp = 100
var is_hooking = false
var hook_target = Vector3.ZERO
@onready var health_bar: ProgressBar = $CanvasLayer/ProgressBar
@onready var hook_cable = $HookLine

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
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		if $Camera3D/RayCast3D.is_colliding():
			hook_target = $Camera3D/RayCast3D.get_collision_point()
			is_hooking = true
	else:
		is_hooking = false
	
	if is_hooking:
		var dir = (hook_target - global_position).normalized()
		velocity = dir * HOOK_SPEED
		hook_cable.visible = true
		var dist = global_position.distance_to(hook_target)
		hook_cable.mesh.height = dist
		hook_cable.global_position = global_position.lerp(hook_target, 0.5)
		hook_cable.look_at(hook_target, Vector3.UP)
		hook_cable.rotate_object_local(Vector3(1,0,0), deg_to_rad(90))
	elif not is_on_floor():
		velocity.y -= gravity * delta
		hook_cable.visible = false
	
	var input_dir := Input.get_vector("a", "d", "w", "s")
	var target_speed = SPEED
	if Input.is_key_pressed(KEY_SHIFT):
		target_speed = SPRINT_SPEED
	current_dynamic_speed = move_toward(current_dynamic_speed, target_speed, acceleration_smoothness * delta)
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_dynamic_speed
		velocity.z = direction.z * current_dynamic_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_dynamic_speed)
		velocity.z = move_toward(velocity.z, 0, current_dynamic_speed)

	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		attack()
	elif Input.is_action_just_pressed('ui_cancel'):
		var menu = get_tree().root.find_child('menu', true, false)
		if menu:
			menu.visible = true
			$CanvasLayer/ProgressBar.visible = false
			get_tree().paused = true
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

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
	
