extends Node2D

@export var obstacle_scene: PackedScene

var obstacle_spawn_interval = 2
@onready var obstacle_spawn_timer = 0.25
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
		spawn_obstacle()


func spawn_obstacle():
	var obstacle = obstacle_scene.instantiate()
	add_child(obstacle)
	#var obstacle_height = obstacle.get_node("CollisionShape2D").shape.size.y/2
	#obstacle.position.x = position.x
	#obstacle.position.y = position.y - obstacle_height/2
	if self.is_in_group("Top Spawner"): pass
	elif self.is_in_group("Bottom Spawner"): pass
	else:
		push_error("Obstacle spawner doesn't have a top/bottom grouping")
