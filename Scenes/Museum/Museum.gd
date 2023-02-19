extends Node2D

var OpenedPaintingScene = preload("res://Entities/OpenedPainting/OpenedPainting.tscn");
var openedPainting;

func _on_Player_user_interacted_with_painting():
	openedPainting = OpenedPaintingScene.instance();
	add_child(openedPainting);

func _physics_process(delta):
	$Camera2D.position = $Player.position;
