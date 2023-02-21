extends Node2D

var hasStarted = false;
signal animation_end;

func _process(delta):
	if (Input.is_action_pressed("ui_accept") and !hasStarted):
		$AnimationPlayer.play("Start");
		hasStarted = true;
		
func onAnimationEnd():
	emit_signal("animation_end")
