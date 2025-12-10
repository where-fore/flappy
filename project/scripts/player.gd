extends RigidBody2D

signal destroyed

var spawn_pause_time = 0.25
@onready var original_modulate = $Sprite2D.modulate

var thrust = Vector2(0, -800)
var anti_bounce_divisor = 1.5
var anti_bounce_threshold_divisor = 8
var torque = 0
@onready var base_rotation = $Sprite2D.rotation_degrees
var rotation_divisor = 30
var rotation_tween = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	freeze = true
	$Sprite2D.modulate = Color(0,0,1,1)
	await get_tree().create_timer(spawn_pause_time).timeout
	$Sprite2D.modulate = original_modulate
	freeze = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	#$Sprite2D.rotation_degrees = base_rotation + linear_velocity.y/rotation_divisor
	#if not rotation_tween: rotate_player()


func _on_body_entered(body: Node) -> void:
	print_debug("player touched: " + body.name)


#should be called by the area2D obstacles when they contact the player
func react_to_obstacle():
	perish()


func perish():
	emit_signal("destroyed")
	self.queue_free()


#should be called by the area2D obstacle pass areas when they contact the player
func pass_obstacle():
	print_debug("score!")


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
