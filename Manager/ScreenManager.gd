extends Node2D

enum Paintings {
	BLUE,
	CLOCKS,
	MONALISA,
	PIXELS,
	SCREAM,
	SKY,
	CENA,
	VAH
}

var levelTitleScene = preload("res://Scenes/LevelTitle/LevelTitle.tscn");
var menuScene = preload("res://Scenes/Menu/Menu.tscn");
var museumScene = preload("res://Scenes/Museum/Museum.tscn");
var prepScene = preload("res://Scenes/Prep/Prep.tscn");
var escapedScene = preload("res://Scenes/Escaped/Escaped.tscn");
var deathScene = preload("res://Scenes/GameOver/GameOver.tscn");
var previousScene;

var time = 0.0;
var isTimerActive = false;
var updateTimerFn;

func _ready():
	var menu = menuScene.instance();
	previousScene = menu;
	menu.connect("animation_end", self, "onMenuAnimationEnd");
	$Scene.add_child(menu);
	$Label.text = String(time);
	$Label.visible = false;

func _process(delta):
	if (isTimerActive):
		time += delta;
		var timerToDisplay = int(time);
		if (previousScene.has_method('updateTimerFn')):
			previousScene.updateTimerFn(timerToDisplay);
		$Label.text = String(timerToDisplay);

func onMenuAnimationEnd():
	var titleLevel = levelTitleScene.instance();
	titleLevel.connect("animation_end", self, "onTitleAnimationEnd");
	previousScene.get_parent().remove_child(previousScene);
	previousScene = titleLevel;
	$Scene.add_child(titleLevel);

func onTitleAnimationEnd():
	var drawLevel = prepScene.instance();
	drawLevel.connect("clicked_done", self, "onDrawingEnd");
	previousScene.get_parent().remove_child(previousScene);
	previousScene = drawLevel;
	$Scene.add_child(drawLevel);
	$Label.visible = true;
	isTimerActive = true;
	
var imageData;
var score;
var scoreAsLabel;

func onDrawingEnd(imageData, score, scoreAsLabel):
	self.imageData = imageData;
	self.score = score;
	self.scoreAsLabel = scoreAsLabel;
	var museumLevel = museumScene.instance();
	museumLevel.setUserDrawing(imageData);
	previousScene.get_parent().remove_child(previousScene);
	previousScene = museumLevel;
	museumLevel.connect("onHeistComplete", self, "onHeistComplete");
	$Scene.add_child(museumLevel);
	$Label.visible = false;
	isTimerActive = true;

func onHeistComplete(swipedPaintingId: int):
	var isCorrect = swipedPaintingId == Paintings.MONALISA;
	var escapedLevel = escapedScene.instance();
	previousScene.get_parent().remove_child(previousScene);
	previousScene = escapedLevel;
	$Scene.add_child(escapedLevel);
	escapedLevel.setState(imageData, score, isCorrect, time);

func onDeath():
	var deathLevel = deathScene.instance();
	previousScene.get_parent().remove_child(previousScene);
	previousScene = deathLevel;
	$Scene.add_child(deathLevel);
	deathLevel.connect("onRestart", self, "onRestartDeath")

func onRestartDeath():
	var museumLevel = museumScene.instance();
	museumLevel.setUserDrawing(imageData);
	previousScene.get_parent().remove_child(previousScene);
	previousScene = museumLevel;
	museumLevel.connect("onHeistComplete", self, "onHeistComplete");
	$Scene.add_child(museumLevel);
	$Label.visible = false;
	isTimerActive = true;
