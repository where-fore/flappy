extends CanvasLayer

var per_score = 1
@onready var label = $"Control/Score Label"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_main_player_scored() -> void:
	var current_score = int(label.text)
	current_score += per_score
	change_label(label, str(current_score))


func _on_main_player_died() -> void:
	change_label(label, str(0))


func change_label(label_to_change:Label, value:String):
	label_to_change.text = value
