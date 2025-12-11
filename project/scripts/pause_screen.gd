extends CanvasLayer

var input_cooldown = 0.01
var input_cooldown_remaining = 0
var fade_tween = null
@onready var fade_rect = $"Control/ColorRect"
@onready var label = $"Control/Label"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if input_cooldown_remaining <= 0:
		if Input.is_action_just_pressed("pause"):
			if not visible: #pause
				get_tree().paused = true
				visible = true
				
				#quick fade in
				#fade_rect.color = Color(0,0,0,0.3)
				fade_tween = create_tween()
				fade_tween.set_trans(Tween.TRANS_EXPO)
				fade_tween.set_ease(Tween.EASE_OUT)
				fade_tween.tween_property(fade_rect, "color", Color(0,0,0,0.75), 0.2)
				await fade_tween.finished
				#pulse
				fade_tween = create_tween()
				fade_tween.set_trans(Tween.TRANS_LINEAR)
				fade_tween.tween_property(fade_rect, "color", Color(0,0,0,0.65), 5)
				fade_tween.tween_property(fade_rect, "color", Color(0,0,0,0.75), 5)
				fade_tween.set_loops() #infinite
				#reset input cooldown
				input_cooldown_remaining = input_cooldown
				
			elif visible: #unpause
				fade_tween.stop()
				
				#text fadeout
				var label_tween = create_tween()
				label_tween.set_trans(Tween.TRANS_EXPO)
				label_tween.set_ease(Tween.EASE_OUT)
				label_tween.tween_property(label, "modulate", Color(0,0,0,0), 0.25)
				
				#quick fadeout
				fade_tween = create_tween()
				fade_tween.set_trans(Tween.TRANS_LINEAR)
				fade_tween.tween_property(fade_rect, "color", Color(0,0,0,0), 0.25)
				await fade_tween.finished
				fade_tween.kill()
				fade_tween = null
				visible = false
				label.modulate = Color(1,1,1,1)
				#once the fade is done and player is ready
				get_tree().paused = false
				input_cooldown_remaining = input_cooldown
				
	elif input_cooldown_remaining > 0: input_cooldown_remaining -= delta
