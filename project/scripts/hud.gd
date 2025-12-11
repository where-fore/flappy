extends CanvasLayer

var per_score:int = 1
@onready var current_score_label = $"Control/Score Label"
@onready var highest_score_label = $"Control/Highest Score Label"
var current_score:int = 0
var highest_score:int = 0
var highest_score_label_text:String = "Best: "

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	highest_score_label.visible = false #so i can see in editor, but not on game start


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_main_player_scored() -> void:
	current_score = int(current_score_label.text)
	current_score += per_score
	change_label(current_score_label, str(current_score))


func _on_main_player_died() -> void:
	#check for new record
	if current_score > highest_score:
		highest_score = current_score
		change_highest_score()
	#clear and restart
	current_score = 0
	change_label(current_score_label, str(current_score))


func change_label(label_to_change:Label, value:String):
	label_to_change.text = value


func change_highest_score():
	if highest_score_label.visible == false: highest_score_label.visible = true
	var label_text:String = highest_score_label_text + str(highest_score)
	change_label(highest_score_label, label_text)
