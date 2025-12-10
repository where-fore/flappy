extends Area2D

var speed = 300

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x -= speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): body.react_to_obstacle()


#make it so this works, but lets them spawn in off screen. some sort of margin
#func _on_visible_on_screen_notifier_2d_screen_exited():
	#print_debug("killed obstacle due to exiting screen")
	#queue_free()
