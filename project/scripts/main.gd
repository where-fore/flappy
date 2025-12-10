extends Node2D

signal player_scored
signal player_died
@export var player_scene: PackedScene

var player_respawn_time = 4
var player_first_spawn_time = 0.25

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	if player_scene == null:
		push_error("Exported variable is null: " + "player_scene")
	spawn_player(player_first_spawn_time)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_player_destroyed() -> void:
	spawn_player(player_respawn_time)
	emit_signal("player_died")


func _on_player_scored() -> void:
	emit_signal("player_scored")


func spawn_player(wait_time:float = 0):
	if wait_time > 0: await get_tree().create_timer(wait_time).timeout
	
	var player = player_scene.instantiate()
	player.position = ($"Player Spawn".position)
	call_deferred("add_child", player)
	player.connect("destroyed", _on_player_destroyed)
	player.connect("scored", _on_player_scored)
