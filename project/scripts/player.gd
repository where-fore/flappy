extends RigidBody2D

signal destroyed
signal scored

var input_cooldown = 0.1
var input_cooldown_remaining = 0
var should_input = false

var spawn_pause_time = 0.5
@onready var original_modulate = $Sprite2D.modulate

var thrust = Vector2(0, -1500)
var clamped_rising_velocity = -200
var clamped_falling_velocity = 300
var anti_bounce_divisor = 1.15
var anti_bounce_threshold_divisor = 0


@onready var base_rotation = $Sprite2D.rotation_degrees
var rotation_divisor = 30
var rotation_tween = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	freeze = true
	
	var tween = create_tween()
	var target = self
	var target_property = "modulate"
	var duration = spawn_pause_time/4
	var original_property = self.modulate
	var end_property = Color(1,1,1,0.25)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(target, target_property, end_property, duration)
	tween.tween_property(target, target_property, original_property, duration)
	tween.set_loops() #infinite
	
	await get_tree().create_timer(spawn_pause_time).timeout
	tween.kill()
	self.modulate = original_property
	
	freeze = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if input_cooldown_remaining >= 0: input_cooldown_remaining -= delta
	
	if Input.is_action_just_pressed("flap") and input_cooldown_remaining <= 0:
		should_input = true
		input_cooldown_remaining = input_cooldown
	
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
	emit_signal("scored")


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if should_input:
		
		#clamp velocities first
		if linear_velocity.y < clamped_rising_velocity:
			linear_velocity.y = clamped_rising_velocity
			print_debug("clamped rising")
		if linear_velocity.y > clamped_falling_velocity:
			linear_velocity.y = clamped_falling_velocity
		
		#provide impulse
		if linear_velocity.y < anti_bounce_threshold_divisor:
			state.apply_central_impulse(thrust/anti_bounce_divisor)
			print_debug("anti bounce triggered")
		else:
			state.apply_central_impulse(thrust)
		
		should_input = false

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
