extends Node2D

@export var obstacle_scene: PackedScene

#farthest out i can put an obstacle and still be on screen
var vertical_screen_size = 720
var bounding_factor = 0.85
var bottom_bound = vertical_screen_size*bounding_factor
var top_bound = vertical_screen_size*(1-bounding_factor)

var should_spawn_obstacles = true

var obstacle_spawn_timer = 0.75
var obstacle_spawn_timer_remaining = obstacle_spawn_timer
var speed_factor


#instantiate difficulty variables
var distance_gap_can_jump
var obstacle_gap_minimum
var obstacle_gap_range
var outer_bound_chance_multiplier
var obstacle_spawn_interval
var obstacle_spawn_interval_variance
var obstacles_spawned_count
func reset_difficulty_variables():
	distance_gap_can_jump = 0.6 #1.0 would mean can go from bottom of screen right to top
	obstacle_gap_minimum = 110.0
	obstacle_gap_range = 60.0
	
	outer_bound_chance_multiplier = 2 #not a literal multiplier, check the function
	
	obstacle_spawn_interval = 1.75 #this is clamped in process()
	obstacle_spawn_interval_variance = 0.15
	
	obstacles_spawned_count = 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset_difficulty_variables()
	
	if obstacle_scene == null:
		push_error("Exported variable is null: " + "obstacle_scene")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if should_spawn_obstacles:
		if obstacle_spawn_timer > 0: obstacle_spawn_timer -= delta
		if obstacle_spawn_timer <= 0:
			spawn_obstacle()
			#reset the timer, with some variance
			var minimum_interval = max(0.25, obstacle_spawn_interval-obstacle_spawn_interval_variance)
			var maximum_interval = min(2.25, obstacle_spawn_interval+obstacle_spawn_interval_variance)
			var spawn_timer = randf_range(minimum_interval, maximum_interval)/(speed_factor/2)
			obstacle_spawn_timer = spawn_timer


func spawn_obstacle():
	#spawn obstacle
	var gap_size = randf_range(obstacle_gap_minimum,obstacle_gap_minimum+obstacle_gap_range)
	var obstacle_group = obstacle_scene.instantiate()
	add_child(obstacle_group)
	var top_obstacle = obstacle_group.get_node("Obstacle (Top)")
	var bottom_obstacle = obstacle_group.get_node("Obstacle (Bottom)")
	top_obstacle.position.y -= gap_size/2
	bottom_obstacle.position.y += gap_size/2
	
	#increment counter (for difficulty)
	obstacles_spawned_count += 1
	
	#make obstacles spawn closer together
	obstacle_gap_minimum /= 1 + (obstacles_spawned_count)/500
	obstacle_gap_range = obstacle_gap_minimum
	
	#make obstacle gaps (able to) spawn further apart
	if distance_gap_can_jump < 1.0:
		distance_gap_can_jump = min(1.0, distance_gap_can_jump + (1.0-distance_gap_can_jump)/40)
	
	#speed up obstacle movement
	speed_factor = min(3, 1+obstacles_spawned_count*0.5)
	#change obstacle_spawn_interval as a factor of speed so they are uniformly far apart as they speed up
	
	var obstacles = get_tree().get_nodes_in_group("Obstacle")
	var obstacle_parents = {}
	for obstacle in obstacles:
		var parent = obstacle.get_parent()
		obstacle_parents[parent.get_instance_id()] = parent
	for parent in obstacle_parents.values():
		#do stuff
		obstacle_group.set_global_speed_factor(speed_factor)
	
	#decouple from spawner
	var saved_position = obstacle_group.global_position
	remove_child(obstacle_group)
	get_parent().add_child(obstacle_group)
	obstacle_group.position = saved_position
	move_gap_center()


func move_gap_center():
	var current_pos = position.y
	
	var topmost = distance_gap_can_jump*(current_pos - top_bound)
	topmost -= current_pos
	if topmost < top_bound*outer_bound_chance_multiplier: topmost = top_bound
	
	var bottommost = distance_gap_can_jump*(bottom_bound - current_pos)
	bottommost += current_pos
	if bottommost > bottom_bound*outer_bound_chance_multiplier: bottommost = bottom_bound
	
	position.y = randf_range(topmost, bottommost)
	
	#double check it's in the play area
	if position.y < top_bound: position.y = top_bound
	if position.y > bottom_bound: position.y = bottom_bound

func _on_main_player_died() -> void:
	should_spawn_obstacles = false
	obstacle_spawn_timer_remaining = obstacle_spawn_timer
	
	#stop spawning obstacles
	var obstacles = get_tree().get_nodes_in_group("Obstacle")
	var obstacle_parents = {}
	for obstacle in obstacles:
		var parent = obstacle.get_parent()
		obstacle_parents[parent.get_instance_id()] = parent
	for parent in obstacle_parents.values():
		parent.speed_up_on_player_death()
	
	reset_difficulty_variables()


func _on_main_player_respawned() -> void:
	should_spawn_obstacles = true
