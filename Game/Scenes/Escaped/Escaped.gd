extends Node2D

var userDrawingTexture;
var score:int;
var isCorrect:bool;
var totalTimer:int;
var level: int;

func _ready():
	$upload.disabled = true;
	$done.visible = false;

func setState(imageTexture, score, isCorrect, totalTimer, level):
	self.userDrawingTexture = imageTexture;
	self.score = score;
	self.isCorrect = isCorrect;
	self.totalTimer = int(totalTimer);
	self.level = level;
	
	if (level >= 3):
		$Button2.visible = false;
	
	$Sprite.texture = imageTexture;
	$Sprite.scale = Vector2($Sprite.scale.x, -$Sprite.scale.y);
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
		
func _on_Button2_pressed():
	uploadScore();

func uploadScore():
	var imageData = $Sprite.texture.get_data();
	imageData.flip_y();
	var buffer = imageData.save_png_to_buffer();
	var asbase64 = Marshalls.raw_to_base64(buffer);
	var query = JSON.print({
		userName = $LineEdit.text,
		rawScore = score,
		scoreLabel = scoreLabel.text,
		time = totalTimer,
		image = asbase64,
		isCorrect = isCorrect,
		level = String(level)
	})
	var headers = ["Content-Type: application/json"]
	$done.text = "LOADING";
	var url = "https://ku62sri6z1.execute-api.eu-west-2.amazonaws.com/score";
	$HTTPRequest.request(url, headers, true, HTTPClient.METHOD_POST, query)
	$upload.visible = false;
	$done.visible = true;


func _on_LineEdit_text_changed(new_text:String):
	$upload.disabled = new_text.length() < 2;


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	$done.text = "DONE";


func _on_next_pressed():
	get_tree().get_root().get_child(0).onNextLevel();
