extends Node2D

signal onRestart;

func _on_Button_pressed():
	emit_signal("onRestart");
