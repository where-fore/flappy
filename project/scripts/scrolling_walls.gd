extends CanvasLayer

var starting_scroll_speed = 0.315
var current_speed = starting_scroll_speed
var scrolling_offset = 0.0
#this effects both walls since they share the shader
@onready var scroll_shader_material = $"Control/Top Wall".material as ShaderMaterial

func _ready() -> void:
	set_shader_scroll_speed(starting_scroll_speed)


func _process(delta: float) -> void:
	scrolling_offset += delta * current_speed
	scroll_shader_material.set_shader_parameter("scroll_offset", scrolling_offset)


func set_shader_scroll_speed(target_speed:float):
	current_speed = target_speed
	scroll_shader_material.set_shader_parameter("speed", current_speed)


func _on_obstacle_spawner_update_speed(speed_factor) -> void:
	set_shader_scroll_speed(current_speed*speed_factor)
