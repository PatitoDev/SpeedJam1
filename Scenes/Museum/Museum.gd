extends Node2D

signal onDeath();
signal onHeistComplete(swipedPaintingId);
var swipedPaintingId;
var OpenedPaintingScene = preload("res://Entities/OpenedPainting/OpenedPainting.tscn");

func _ready():
	VisualServer.set_default_clear_color(Color('#090909'));

func _on_Player_user_interacted_with_painting(selectedPainting: Node2D):
	print(selectedPainting);
	$Camera2D/OpenedPaintingOverlay.showPainting(selectedPainting.selectedPainting);

func _physics_process(delta):
	$Camera2D.position = $Player.position;

func updateTimerFn(time: int):
	$Camera2D/TimerLabel.text = String(time);
	
func setUserDrawing(imageData):
	$Camera2D/OpenedPaintingOverlay.setUserDrawing(imageData);

func _on_Area2D_body_entered(body):
	if (swipedPaintingId != null):
		emit_signal("onHeistComplete", swipedPaintingId);

func onSwiped(swipeId: int):
	swipedPaintingId = swipeId;
