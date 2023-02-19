extends Node2D

const BRUSH_SIZE_MULTIPLAYER = 5;
var pixelationAmount = 30;
var activeLine = null;
var currentSize = 5;
var currentColor = Color.white;
var timer;
var targetPixelPicture;

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
	var image = Image.new();
	image.load("res://Entities/Painting/img/monalisa.png");
	var pixelatedImage = pixelateImage(image);
	targetPixelPicture = pixelatedImage.get_data();
	pixelatedImage.resize(image.get_size().x, image.get_size().y, Image.INTERPOLATE_NEAREST);
	texture2.create_from_image(pixelatedImage);
	$Test/test.texture = texture2;
	var texture = ImageTexture.new();
	texture.create_from_image(image);

func loadImage():
	var image = Image.new();
	image.load("res://Entities/Painting/img/monalisa.png");
	var size = image.get_size();
	$Canvas.rect_size = size;
	$Canvas/Viewport.size = size;
	$Canvas/Viewport/ColorRect.rect_size = size;
	var mainTexture = ImageTexture.new();
	mainTexture.create_from_image(image);
	$Original.texture = mainTexture;

func _ready():
	loadImage();
	testTexture();
	$BrushSizeSlider.value = currentSize;
	$ColorPicker.color = currentColor;
	timer = Timer.new();
	timer.one_shot = false;
	timer.connect("timeout", self, "onTimerTimeout");
	timer.paused = false;
	timer.autostart = true;
	timer.wait_time = 5;
	add_child(timer);

func onTimerTimeout():
	var userImage = $Canvas/Viewport.get_texture().get_data();
	userImage.flip_y();
	var pixelatedUserImage = pixelateImage(userImage);
	var pixelatedUserData = pixelatedUserImage.get_data();
	
	var totalDiff = 0;
	for i in range(pixelatedUserData.size()):
		totalDiff += abs(pixelatedUserData[i] - targetPixelPicture[i]);
	var averageDiff = totalDiff / pixelatedUserData.size(); 
	$Label.text = String(averageDiff);
	
	var image = Image.new();
	var texture2 = ImageTexture.new();
	image.load("res://Entities/Painting/img/monalisa.png");
	pixelatedUserImage.resize(image.get_size().x, image.get_size().y, Image.INTERPOLATE_NEAREST);
	texture2.create_from_image(pixelatedUserImage);
	$Test/test2.texture = texture2;

func _physics_process(delta):
	pass
	
func _input(event):
   # Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		if (event.pressed):
			onDrawStart(event);
		else:
			onDrawEnd(event);
	elif event is InputEventMouseMotion:
		if (activeLine != null):
			onMouseMove(event);
   # Print the size of the viewport.
   #print("Viewport Resolution is: ", get_viewport_rect().size)

func calculateOffset(eventPosition: Vector2):
	var offset = $Canvas.rect_position;
	return Vector2(eventPosition.x - offset.x, eventPosition.y - offset.y);
	
func onDrawStart(event: InputEventMouseButton):
	activeLine = Line2D.new();
	activeLine.begin_cap_mode = Line2D.LINE_CAP_ROUND;
	activeLine.end_cap_mode = Line2D.LINE_CAP_ROUND;
	activeLine.antialiased = true;
	activeLine.joint_mode = true;
	activeLine.width = currentSize;
	activeLine.default_color = currentColor;
	activeLine.add_point(calculateOffset(event.position));
	$Canvas/Viewport/DrawingTarget.add_child(activeLine);

func onDrawEnd(event: InputEventMouseButton):
	if (activeLine != null):
		activeLine.add_point(calculateOffset(event.position));
		activeLine = null;
	
func onMouseMove(event: InputEventMouseMotion):
	if (activeLine != null):
		activeLine.add_point(calculateOffset(event.position));

func _on_VSlider_value_changed(value):
	var newValue = 	value * BRUSH_SIZE_MULTIPLAYER;
	currentSize = newValue;
	if (activeLine != null):
		activeLine.width = newValue;

func _on_ColorPickerButton_color_changed(color: Color):
	currentColor = color;
	if (activeLine != null):
		activeLine.default_color = color;

func _on_HideOverlayButton_pressed():
	$Overlay.visible = !$Overlay.visible;
