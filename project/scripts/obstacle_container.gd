extends Node2D

var speed = 250

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x -= speed * delta


func _on_pass_check_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): body.pass_obstacle()
