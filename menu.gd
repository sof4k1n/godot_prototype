extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE # Replace with function body.\
	self.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_contininue_button_pressed():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	self.visible = false
	var player = get_tree().current_scene.find_child('player', true, false)
	if player:
		player.get_node('CanvasLayer/ProgressBar').visible = true
	get_tree().paused = false

func _on_settings_button_pressed():
	pass
	
func _on_exit_button_pressed():
	get_tree().quit()
