extends Area2D

signal wall_destroyed

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): body.react_to_obstacle()

#only used for walls, not tall obstacles
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	emit_signal("wall_destroyed", get_groups())
	queue_free()
