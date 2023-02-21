extends Node2D

signal animation_end;

var hasFiredSignal = false;

func _ready():
	$AnimationPlayer.play("end");

func setTitle(level: int, paintingName: String):
	$Node/Node2D3/LevelLabel.text = paintingName;
	$Node/Node2D2/Label.text = "LEVEL " + String(level);
	
func OnTimerEnd():
	if (!hasFiredSignal):
		emit_signal("animation_end");
	
func _physics_process(delta):
	if (Input.is_action_pressed("ui_accept")):
		hasFiredSignal = true;
		emit_signal("animation_end");
