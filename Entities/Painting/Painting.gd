extends Node2D


signal PaintingInteractionStarted;

func _physics_process(delta):
	if (Input.is_action_just_pressed("ui_accept")):
		emit_signal("PaintingInteractionStarted");
