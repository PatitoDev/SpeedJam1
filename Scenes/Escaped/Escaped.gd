extends Node2D

func setState(imageTexture, score, isCorrect, totalTimer):
	$Sprite.texture = imageTexture;
	$Sprite.rotation_degrees = 180;
	if (!isCorrect):
		$Node2D/Label2.text = "THE WRONG PAINTING!"
	else:
		$Node2D/Label2.text = "THE RIGHT PAINTING!"
	
	$Node2D/seconds.text = "IN "  + String(int(totalTimer)) + " SECONDS"
	updateScore(score);

onready var scoreLabel = $Node2D/score;

func updateScore(averageDiff: int):
	var displayText = 'FAKE';
	var color = Color("FF3636");
	if (averageDiff <= 5):
		displayText = 'IMPOSSIBLE';
		color = Color("27FFFF");
	elif (averageDiff <= 10):
		displayText = 'QUACKASTIC';
		color = Color("FF18E8");
	elif (averageDiff <= 15):
		displayText = 'PERFECT';
		color = Color("05FF00");
	elif (averageDiff <= 30):
		displayText = 'GOOD';
		color = Color("FAFF00");
	elif (averageDiff <= 100):
		displayText = 'BAD';
		color = Color("FF630B");
	scoreLabel.text = displayText;
	scoreLabel.add_color_override("font_color", color);


func _on_Button_pressed():
	if (!$Credits.visible):
		$Credits.visible = true;
		$Button.text = "BACK";
	else:
		$Credits.visible = false;
		$Button.text = "CREDITS";
