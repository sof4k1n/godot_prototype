extends CharacterBody3D


const SPEED = 2.0
var hp = 3
@onready var player = get_tree().root.find_child('player', true, false)

func _physics_process(delta: float) -> void:
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	move_and_slide()

func take_damage(amount):
	hp -= amount
	if hp <= 0:
		queue_free()
 
func _on_attack_area_body_entered(body):
	if body.is_in_group('player'):
		if body.has_method('take_damage'):
			body.take_damage(10)
