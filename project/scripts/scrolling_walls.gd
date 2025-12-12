extends CanvasLayer

var starting_scroll_speed = 0.315
var parallax_factor = 0.8


var current_speed_factor = 1
var current_speed = starting_scroll_speed
var scrolling_offset = 0.0
#this effects both walls since they share the shader
@onready var scroll_shader_material = $"Control/Top Wall".material as ShaderMaterial

func _process(delta: float) -> void:
	scrolling_offset += delta * current_speed
	scroll_shader_material.set_shader_parameter("scroll_offset", scrolling_offset)


func _on_obstacle_spawner_update_speed(speed_factor) -> void:
	if current_speed_factor != speed_factor:
		var diff = 0
		if not current_speed_factor == 0:
			diff = speed_factor/current_speed_factor
			
		var diff_after_parallax = ((diff-1)*parallax_factor)+1
		current_speed *= diff_after_parallax
		current_speed_factor = speed_factor


func _on_obstacle_spawner_player_died_pause() -> void:
	current_speed = 0


func _on_main_player_respawned() -> void:
	current_speed = starting_scroll_speed
	current_speed_factor = 1
