extends RigidBody2D

signal destroyed
signal scored

var input_cooldown = 0.1
var input_cooldown_remaining = 0
var should_input = false

var spawn_pause_time = 0.5

var thrust = Vector2(0, -1500)
var clamped_rising_velocity = -200
var clamped_falling_velocity = 300
var anti_bounce_divisor = 1.15
var anti_bounce_threshold_divisor = 0

var sprite_change_timer = 0.4
var sprite_change_timer_remaining = 0
var should_check_sprites = false

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
	if input_cooldown_remaining > 0: input_cooldown_remaining -= delta
	
	if Input.is_action_just_pressed("flap") and input_cooldown_remaining <= 0 and freeze == false:
		should_input = true
		input_cooldown_remaining = input_cooldown

	
	if sprite_change_timer_remaining > 0: sprite_change_timer_remaining -= delta
	if sprite_change_timer_remaining <= 0:
		if should_check_sprites == true: tween_sprites(false)

func _on_body_entered(_body: Node) -> void:
	#print_debug("player touched: " + _body.name)
	pass


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
	#if an input is in queue:
	if should_input:
		
		#clamp velocities first
		if linear_velocity.y < clamped_rising_velocity:
			linear_velocity.y = clamped_rising_velocity
			#print_debug("clamped rising")
		if linear_velocity.y > clamped_falling_velocity:
			linear_velocity.y = clamped_falling_velocity
		
		#provide impulse
		if linear_velocity.y < anti_bounce_threshold_divisor:
			state.apply_central_impulse(thrust/anti_bounce_divisor)
			#print_debug("anti bounce triggered")
		else:
			state.apply_central_impulse(thrust)
		
		#change sprites on input
		tween_sprites(true)
		sprite_change_timer_remaining = sprite_change_timer
		should_check_sprites = true
		
		#reset queue
		should_input = false

func tween_sprites(fade_in:bool):
	var tween = create_tween()
	var target = $BodySprite/BodyWithFireSprite
	var target_property = "modulate"
	var duration = 0.25
	var target_property_value = null
	tween.set_trans(Tween.TRANS_EXPO)
	if fade_in:
		target_property_value = Color(1,1,1,1)
		tween.set_ease(Tween.EASE_OUT)
	else:
		target_property_value = Color(1,1,1,0)
		tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(target, target_property, target_property_value, duration)
