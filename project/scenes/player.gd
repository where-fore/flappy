extends RigidBody2D


var thrust = Vector2(0, -800)
var anti_bounce_divisor = 1.5
var anti_bounce_threshold_divisor = 8
var torque = 0
@onready var base_rotation = $Sprite2D.rotation_degrees
var rotation_divisor = 30
var rotation_tween = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	#$Sprite2D.rotation_degrees = base_rotation + linear_velocity.y/rotation_divisor
	#if not rotation_tween: rotate_player()


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if Input.is_action_just_pressed("ui_up"):
		if linear_velocity.y < abs(thrust.y/anti_bounce_threshold_divisor):
			state.apply_central_impulse(thrust/anti_bounce_divisor)
			#print_debug("anti bounce triggered")
		else: state.apply_central_impulse(thrust)

func rotate_player():
	var target = $Sprite2D
	var target_property = "rotation_degrees"
	var new_rotation = base_rotation + linear_velocity.y/rotation_divisor
	var time = 0.15
	rotation_tween = create_tween()
	rotation_tween.set_trans(Tween.TRANS_LINEAR)
	#tween.set_ease(Tween.EASE_IN_OUT)
	rotation_tween.tween_property(target, target_property, new_rotation, time)
	
	await rotation_tween.finished
	rotation_tween.kill()
	rotation_tween = null
