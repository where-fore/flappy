extends Node2D

@export var obstacle_scene: PackedScene

signal update_speed

#farthest out i can put an obstacle and still be on screen
#note this doesn't ever check the obstacle sprite or collider or anything
#just the center where an obstacle gap can be created
var vertical_screen_size = 720
var bounding_factor = 0.75
var bottom_bound = vertical_screen_size*bounding_factor
var top_bound = vertical_screen_size*(1-bounding_factor)

var should_spawn_obstacles = true

var obstacle_spawn_timer_first = 0.50 #time before first obstacle spawns, not every
var obstacle_spawn_timer_remaining = obstacle_spawn_timer_first

#difficulty variables
#static difficulty variables
var speed_factor_maximum = 1.5
var speed_factor_per_obstacle = 0.025
var gap_reduction_per_obstacle = 0.005 #percent, so 0.1 is 10% closer gaps
var gap_range_reduction_per_obstacle = 0.03 #percent, so 0.1 is 10% less variance in gaps
var obstacle_gap_absolute_minimum = 110.0 #double check this when changing character controller
var obstacle_gap_range_minimum = 20.0 #double check when changing above
var distance_gap_can_jump_per_obstacle = 0.01
var distance_gap_can_jump_maximum = 1.0 #whole screen, can increase over 1.0 for chance to go to outer bounds
var outer_bound_chance_multiplier = 2 #not a literal multiplier, check the function
var obstacle_spawn_interval_minimum = 1.5
var obstacle_spawn_interval_maximum = 3


#difficulty variables that change and should be reset
var distance_gap_can_jump
var obstacle_gap_minimum
var obstacle_gap_range
var obstacle_spawn_interval
var obstacle_spawn_interval_variance
var obstacles_spawned_count
var speed_factor
#starting values for these variables which change often and quickly
func reset_difficulty_variables():
	distance_gap_can_jump = 0.6 #1.0 would mean can go from bottom of screen right to top
	
	obstacle_gap_minimum = 160.0
	obstacle_gap_range = 80.0 #how much higher than the minimum a gap size can be
	
	obstacle_spawn_interval = 2.00 #this is clamped in process()
	obstacle_spawn_interval_variance = 0.20
	
	obstacles_spawned_count = 0.0 #can change this to start at certain difficulties
	
	speed_factor = 1.0 #game speeds up by this factor as it goes on, up to a maximum


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset_difficulty_variables()
	
	if obstacle_scene == null:
		push_error("Exported variable is null: " + "obstacle_scene")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if should_spawn_obstacles:
		if obstacle_spawn_timer_remaining > 0: obstacle_spawn_timer_remaining -= delta
		if obstacle_spawn_timer_remaining <= 0:
			spawn_obstacle()
			#reset the timer, with some variance
			var attempted_minimum_interval = (obstacle_spawn_interval-obstacle_spawn_interval_variance) / speed_factor
			var minimum_interval = max(obstacle_spawn_interval_minimum, attempted_minimum_interval)
			var attempted_maximum_interval = (obstacle_spawn_interval + obstacle_spawn_interval_variance) / speed_factor
			var maximum_interval = min(obstacle_spawn_interval_maximum, attempted_maximum_interval)
			
			var spawn_timer = randf_range(minimum_interval, maximum_interval)
			obstacle_spawn_timer_remaining = spawn_timer


func spawn_obstacle():
	#spawn obstacle
	var gap_size = randf_range(obstacle_gap_minimum,obstacle_gap_minimum+obstacle_gap_range)
	var obstacle_group = obstacle_scene.instantiate()
	add_child(obstacle_group)
	var top_obstacle = obstacle_group.get_node("Obstacle (Top)")
	var bottom_obstacle = obstacle_group.get_node("Obstacle (Bottom)")
	top_obstacle.position.y -= gap_size/2
	bottom_obstacle.position.y += gap_size/2
	
	#decouple from spawner
	var saved_position = obstacle_group.global_position
	remove_child(obstacle_group)
	get_parent().add_child(obstacle_group)
	obstacle_group.position = saved_position
	
	#change some stuff per obstacle spawned
	update_difficulty()
	
	#change where the next one will spawn
	move_gap_center()
	

func update_difficulty():
	#increment counter (for difficulty)
	obstacles_spawned_count += 1
	
	#make obstacles spawn closer together
	var debug_string = []
	debug_string.append_array(["obstacle_gap_minimum", "was", obstacle_gap_minimum])
	
	var attempted_gap_minimum = roundf(obstacle_gap_minimum / (1 + (obstacles_spawned_count)*gap_reduction_per_obstacle))
	obstacle_gap_minimum = max(obstacle_gap_absolute_minimum, attempted_gap_minimum)
	
	debug_string.append_array(["obstacle_gap_minimum", "is now", obstacle_gap_minimum])
	print(" ".join(debug_string))
	debug_string.clear()
	
	#make obstacles more frequently spawn closer together
	debug_string.append_array(["obstacle_gap_range", "was", obstacle_gap_range])
	
	var attempted_gap_range_minimum = roundf(obstacle_gap_range / (1 + (obstacles_spawned_count)*gap_range_reduction_per_obstacle))
	obstacle_gap_range = max(obstacle_gap_range_minimum, attempted_gap_range_minimum)
	
	debug_string.append_array(["obstacle_gap_range", "is now", obstacle_gap_range])
	print(" ".join(debug_string))
	debug_string.clear()
	
	#make obstacle gaps (able to) spawn further vertically separated, sequentially (eg. very top then very bottom)
	debug_string.append_array(["distance_gap_can_jump", "was", distance_gap_can_jump])
	
	var increase = snappedf(obstacles_spawned_count*distance_gap_can_jump_per_obstacle, 0.01)
	var attempted_gap_distance = distance_gap_can_jump + increase
	distance_gap_can_jump = min(distance_gap_can_jump_maximum, attempted_gap_distance)
	
	debug_string.append_array(["distance_gap_can_jump", "is now", distance_gap_can_jump])
	print(" ".join(debug_string))
	debug_string.clear()
	
	#this one is a bit cumbersome so it got its own function
	update_obstacle_speeds()


#speed up obstacle movement: the spawn time is changed in process()
func update_obstacle_speeds():
	var debug_string = []
	debug_string.append_array(["speed_factor", "was", speed_factor])
	
	speed_factor = min(speed_factor_maximum, 1+obstacles_spawned_count*speed_factor_per_obstacle)
	
	debug_string.append_array(["speed_factor", "is now", speed_factor])
	print(" ".join(debug_string))
	debug_string.clear()
	print("------------", "\n")
	
	#grab every obstacle
	var obstacles = get_tree().get_nodes_in_group("Obstacle")
	var obstacle_parents = {}
	#grab their parents
	for obstacle in obstacles:
		var parent = obstacle.get_parent()
		#overwrite duplicates
		obstacle_parents[parent.get_instance_id()] = parent
	#do stuff to each parent
	for parent in obstacle_parents.values():
		parent.set_global_speed_factor(speed_factor)
	
	#upgdate the background wall speeds too
	emit_signal("update_speed", speed_factor)


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
	obstacle_spawn_timer_remaining = obstacle_spawn_timer_first
	
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
