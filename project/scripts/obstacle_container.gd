extends Node2D

var speed = 250
var speed_on_death_factor = 2.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x -= speed * delta

func speed_up_on_player_death():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "speed", speed * speed_on_death_factor, 1)

func _on_pass_check_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): body.pass_obstacle()
