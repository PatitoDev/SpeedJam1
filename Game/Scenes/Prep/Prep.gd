extends Node2D

signal clicked_done(drawnedImageAsData, score, scoreAsLabel);

var pixelationAmount = 30;
var activeLine: Line2D = null;
var currentSize = 25;
var currentColor = Color.white;
var timer;
var targetPixelPicture;
onready var pickerIcon = preload("res://Icons/picker.png");
onready var brushIconSmall: StreamTexture = preload("res://Icons/brush.png");
onready var brushIconBig: StreamTexture = preload("res://Icons/brush_big.png");
var monalisaImage;

onready var canvas = $LeftCanvas/Canvas;
onready var testTexture = $Test/test;
onready var test2Texture = $Test/test2;
onready var drawingTarget = $LeftCanvas/Canvas/Viewport/DrawingTarget;
onready var overlay = $LeftCanvas/Overlay;
onready var audioPlayer = $AudioPlayer;
onready var scoreLabel = $ScoreLabel;
onready var picker = $LeftCanvas/PickerContainer/Picker;#
onready var toggleOverlayButton = $LeftCanvas/ToggleOverlayButton;
onready var brushSoftAudios = [
	load("res://sounds/paint_brush_soft_1.wav"),
	load("res://sounds/paint_brush_soft_2.wav"),
	load("res://sounds/paint_brush_soft_3.wav"),
	load("res://sounds/paint_brush_soft_4.wav"),
];

onready var brushHardAudios = [
	load("res://sounds/paint_brush_hard_1.wav"),
	load("res://sounds/paint_brush_hard_2.wav"),
	load("res://sounds/paint_brush_hard_3.wav"),
	load("res://sounds/paint_brush_hard_4.wav"),
];

enum Tools {
	PAINT_BRUSH,
	COLOR_PICKER
}
var activeTool = Tools.PAINT_BRUSH;
var isInsideDrawingCanvas = false;

var score = 10000000;
var targetSprite:Sprite;

export var level = 3;
func setLevel(newLevel: int):
	level = newLevel;
	match (level):
		1:
			targetSprite = $"RightCanvas/1";
			$"RightCanvas/1".visible = true;
		2:
			targetSprite = $"RightCanvas/2";
			$"RightCanvas/2".visible = true;
		3:
			targetSprite = $"RightCanvas/3";
			$"RightCanvas/3".visible = true;
			
	overlay.texture = targetSprite.texture;
	overlay.position = $LeftCanvas/Canvas.rect_position;
	var size = targetSprite.texture.get_size();
	var texture = targetSprite.texture.get_data().get_data();
	monalisaImage = Image.new();
	monalisaImage.create_from_data(size.x, size.y, false, Image.FORMAT_RGB8, texture);
	loadImage();
	testTexture();
	timer = Timer.new();
	timer.one_shot = false;
	timer.connect("timeout", self, "onTimerTimeout");
	timer.paused = false;
	timer.autostart = true;
	timer.wait_time = 5;
	add_child(timer);

func _ready():
	$LeftCanvas/BrushSizeSlider.value = currentSize;
	changeTool(Tools.PAINT_BRUSH);
	recalculateBrushSizeIcon();
	changePickerColor(currentColor);
	hideOverlay();
	updateScore(score);

func _physics_process(delta):
	if (Input.is_action_just_pressed("back")):
		var children = drawingTarget.get_children();
		var size = children.size();
		if (size >= 1):
			var node = children[size - 1];
			node.get_parent().remove_child(node);

func updateScore(averageDiff: int):
	score = averageDiff;
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
	$Test/SimilarityScore.text = String(averageDiff);

func calculateAverageColor(image:Image):
	var data = image.get_data();
	var numberOfPixels = data.size() / 3;
	var pixelSum = Vector3(0,0,0);
	for i in range(numberOfPixels):
		var pixelIndex = i * 3
		pixelSum.x += data[pixelIndex]; 	#r
		pixelSum.y += data[pixelIndex + 1]; #g
		pixelSum.z += data[pixelIndex + 2]; #b
	return Vector3(
		int(pixelSum.x / numberOfPixels),
		int(pixelSum.y / numberOfPixels),
		int(pixelSum.z / numberOfPixels)
	);

func pixelateImage(image: Image):
	var imageSize = Vector2(image.get_width(), image.get_height());
	var windowSize:Vector2 = Vector2(
		floor(imageSize.x / pixelationAmount),
		floor(imageSize.y / pixelationAmount)
	);
	
	var numberOfColumns = floor(imageSize.x / windowSize.x);
	var numberOfRows = floor(imageSize.y / windowSize.y);
	var totalWindows = numberOfColumns * numberOfRows;
	
	var simpleImageData = [];
	for column in range(numberOfColumns):
		for row in range(numberOfRows):
			var section = Vector2(row * windowSize.x, column * windowSize.y);
			var window = image.get_rect(Rect2(section, windowSize));
	
			var numberOfPixels = window.get_data().size() / 3;
			var averageColor = calculateAverageColor(window);
			simpleImageData.push_back(averageColor);
	
	var newImageData = [];
	for pixel in simpleImageData:
		newImageData.push_back(pixel.x);
		newImageData.push_back(pixel.y);
		newImageData.push_back(pixel.z);
	var calculatedImage = Image.new();
	calculatedImage.create_from_data(numberOfRows, numberOfColumns, false, Image.FORMAT_RGB8, newImageData);
	return calculatedImage;

func testTexture():
	var texture2 = ImageTexture.new();
	var image = monalisaImage;
	var pixelatedImage = pixelateImage(image);
	targetPixelPicture = pixelatedImage.get_data();
	pixelatedImage.resize(image.get_size().x, image.get_size().y, Image.INTERPOLATE_NEAREST);
	texture2.create_from_image(pixelatedImage);
	testTexture.texture = texture2;
	var texture = ImageTexture.new();
	texture.create_from_image(image);

func loadImage():
	var image = monalisaImage;
	var size = image.get_size();
	canvas.rect_size = size;
	$LeftCanvas/Canvas/Viewport.size = size;
	$LeftCanvas/Canvas/Viewport/ColorRect.rect_size = size;
	var mainTexture = ImageTexture.new();
	mainTexture.create_from_image(image);
	targetSprite.texture = mainTexture;

func onTimerTimeout():
	var userImage = $LeftCanvas/Canvas/Viewport.get_texture().get_data();
	userImage.flip_y();
	var pixelatedUserImage = pixelateImage(userImage);
	var pixelatedUserData = pixelatedUserImage.get_data();
	
	var totalDiff = 0;
	for i in range(pixelatedUserData.size()):
		totalDiff += abs(pixelatedUserData[i] - targetPixelPicture[i]);
	var averageDiff = totalDiff / pixelatedUserData.size();
	updateScore(averageDiff);
	
	#var image = monalisaImage;
	#var texture2 = ImageTexture.new();
	#pixelatedUserImage.resize(image.get_size().x, image.get_size().y, Image.INTERPOLATE_NEAREST);
	#texture2.create_from_image(pixelatedUserImage);
	#test2Texture.texture = texture2;
	
func _input(event):
   # Mouse in viewport coordinates.
	match (activeTool):
		Tools.PAINT_BRUSH:
			if (!isInsideDrawingCanvas):
				return;
			if event is InputEventMouseButton:
				if (event.pressed):
					onDrawStart(event);
				else:
					onDrawEnd(event);
			elif event is InputEventMouseMotion:
				if (activeLine != null):
					onMouseMove(event);
		Tools.COLOR_PICKER:
			if event is InputEventMouseButton:
				var screenshot = get_viewport().get_texture().get_data();
				screenshot.lock();
				screenshot.flip_y();
				var pickedColor = screenshot.get_pixel(event.position.x, event.position.y);
				changePickerColor(pickedColor);
				changeTool(Tools.PAINT_BRUSH);

func changePickerColor(color: Color):
	currentColor = color;
	var style = StyleBoxFlat.new();
	style.bg_color = currentColor;
	picker.add_stylebox_override("normal", style);
	picker.add_stylebox_override("hover", style);
	picker.add_stylebox_override("pressed", style);

func changeTool(toolToChange):
	match (toolToChange):
		Tools.PAINT_BRUSH:
			activeTool = Tools.PAINT_BRUSH;
			recalculateBrushSizeIcon();
			#Input.set_custom_mouse_cursor(brushIcon, Input.CURSOR_ARROW, Vector2(32, 32));
		Tools.COLOR_PICKER:
			activeTool = Tools.COLOR_PICKER;
			Input.set_custom_mouse_cursor(pickerIcon, Input.CURSOR_ARROW, Vector2(5, 57));

func recalculateBrushSizeIcon():
	var newSize = ((64 / 50) * currentSize) + 10;
	var targetBrush = brushIconSmall;
	if (currentSize >= 20):
		targetBrush = brushIconBig;	
	var imageData:Image = targetBrush.get_data();
	imageData.resize(newSize, newSize, Image.INTERPOLATE_NEAREST);
	var texture = ImageTexture.new();
	texture.create_from_image(imageData);
	Input.set_custom_mouse_cursor(texture, Input.CURSOR_ARROW, Vector2(newSize / 2, newSize / 2));

func calculateOffset(withOffset: bool = false):
	var mousePosition = $LeftCanvas/Canvas/Viewport.get_mouse_position();
	var targetRotation = -$LeftCanvas.rotation;
	if (withOffset):
		mousePosition += Vector2(1, 1);
	return mousePosition.rotated(targetRotation);

func onDrawStart(event: InputEventMouseButton):
	activeLine = Line2D.new();
	activeLine.begin_cap_mode = Line2D.LINE_CAP_ROUND;
	activeLine.end_cap_mode = Line2D.LINE_CAP_ROUND;
	activeLine.antialiased = true;
	activeLine.joint_mode = true;
	activeLine.width = currentSize;
	activeLine.default_color = currentColor;
	activeLine.add_point(calculateOffset());
	drawingTarget.add_child(activeLine);
	if (audioPlayer.playing == false):
		if (currentSize < 5):
			var randomIndex = randi() % (brushSoftAudios.size() - 1);
			audioPlayer.stream = brushSoftAudios[randomIndex];
		else:
			var randomIndex = randi() % (brushHardAudios.size() - 1);
			audioPlayer.stream = brushHardAudios[randomIndex];
		audioPlayer.play(0);

func onDrawEnd(event: InputEventMouseButton):
	if (activeLine != null):
		if (activeLine.points.size() == 1):
			activeLine.add_point(calculateOffset(true));
		activeLine = null;
	
func onMouseMove(event: InputEventMouseMotion):
	if (activeLine != null):
		activeLine.add_point(calculateOffset());

func _on_VSlider_value_changed(value):
	var newValue = value;
	currentSize = newValue;
	recalculateBrushSizeIcon();
	if (activeLine != null):
		activeLine.width = newValue;

func _on_ColorPickerButton_color_changed(color: Color):
	currentColor = color;
	if (activeLine != null):
		activeLine.default_color = color;

func _on_HideOverlayButton_pressed():
	if (overlay.visible):
		hideOverlay();
		return
	showOverlay();

func _on_Picker_pressed():
	changeTool(Tools.COLOR_PICKER);

func _on_Canvas_mouse_entered():
	isInsideDrawingCanvas = true;

func _on_Canvas_mouse_exited():
	isInsideDrawingCanvas = false;

func showOverlay():
	overlay.visible = !overlay.visible;
	toggleOverlayButton.text = 'HIDE OVERLAY';

func hideOverlay():
	overlay.visible = !overlay.visible;
	toggleOverlayButton.text = 'SHOW OVERLAY';

func _on_DoneButton_pressed():
	var userImage = $LeftCanvas/Canvas/Viewport.get_texture();
	emit_signal("clicked_done", userImage, score, scoreLabel.text);
