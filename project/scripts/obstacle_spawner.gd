extends Node2D

@export var obstacle_scene: PackedScene

var obstacle_spawn_interval = 2
@onready var obstacle_spawn_timer = 0.75
var vertical_screen_size = 720

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if obstacle_scene == null:
		push_error("Exported variable is null: " + "obstacle_scene")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if obstacle_spawn_timer > 0: obstacle_spawn_timer -= delta
	if obstacle_spawn_timer <= 0:
		obstacle_spawn_timer = obstacle_spawn_interval
		spawn_obstacle(randf_range(200,500))


func spawn_obstacle(gap:float):
	var obstacle_group = obstacle_scene.instantiate()
	add_child(obstacle_group)
	var top_obstacle = obstacle_group.get_node("Obstacle (Top)")
	var bottom_obstacle = obstacle_group.get_node("Obstacle (Bottom)")
	top_obstacle.position.y -= gap/2
	bottom_obstacle.position.y += gap/2
