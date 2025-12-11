extends Area2D

signal wall_destroyed

var speed = 160 #consider changing the obstacle speed to the same
var parallax_factor = 0.85
var global_speed_factor = 1

func _process(delta: float) -> void:
	position.x -= speed * delta * parallax_factor * global_speed_factor


func set_global_speed_factor(factor:float):
	global_speed_factor = factor


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): body.react_to_obstacle()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	emit_signal("wall_destroyed", get_groups())
	queue_free()
