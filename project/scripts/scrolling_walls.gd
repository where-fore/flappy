extends CanvasLayer

var starting_scroll_speed = 0.315
var parallax_factor = 0.8


var current_speed_factor = 1
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
	scroll_shader_material.set_shader_parameter("speed", target_speed)


func _on_obstacle_spawner_update_speed(speed_factor) -> void:
	if current_speed_factor != speed_factor:
		var diff = speed_factor/current_speed_factor
		var diff_after_parallax = ((diff-1)*parallax_factor)+1
		current_speed *= diff_after_parallax
		current_speed_factor = speed_factor
		set_shader_scroll_speed(current_speed)
