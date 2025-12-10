extends RigidBody2D


var thrust = Vector2(0, -800)
var anti_bounce_denominator = 1.5
var torque = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if Input.is_action_just_pressed("ui_up"):
		if linear_velocity.y < abs(thrust.y/8):
			state.apply_central_impulse(thrust/anti_bounce_denominator)
			print_debug("anti bounce")
		else: state.apply_central_impulse(thrust)
