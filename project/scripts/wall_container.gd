extends Node2D

@export var top_wall_scene: PackedScene
@export var bottom_wall_scene: PackedScene

var current_global_speed = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	attach_signals()


func attach_signals():
	for child in get_children():
		child.connect("wall_destroyed", _on_wall_destroyed)


func _on_wall_destroyed(group_array:Array):
	if group_array.has("Bottom Wall"):
		spawn_wall(bottom_wall_scene)
	elif group_array.has("Top Wall"):
		spawn_wall(top_wall_scene)
	else: push_error("Destroyed Wall has no valid Group")


func spawn_wall(wall_scene):
	var new_wall = wall_scene.instantiate()
	new_wall.set_global_speed_factor(current_global_speed)
	#call_deferred("add_child", new_wall)
	add_child(new_wall)
	new_wall.connect("wall_destroyed", _on_wall_destroyed)


func _on_obstacle_spawner_update_speed(factor:float) -> void:
	current_global_speed = factor
	for child in get_children():
		child.set_global_speed_factor(factor)
