extends Node2D

signal onPaintingSwiped(paintingId)

# TODO - REMOVE DUPLICATE ENUM;
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

var hasSwiped = false;
var displayedImage;
var displayedImageId;

func _ready():
	visible = false;
	$Fake/UserPainting.visible = false;

func swipePainting():
	if (!hasSwiped):
		hasSwiped = true;
		$Fake/UserPainting.visible = true;
		$AnimationPlayer.play("Swipe");
		$Info.visible = false;
		var a = self.get_parent().get_parent();
		a.onSwiped(displayedImageId);

func onSwipeComplete():
	displayedImage.texture = $Fake/UserPainting.texture;
	displayedImage.rotation_degrees = 180;

func setUserDrawing(imageData: ViewportTexture):
	$Fake/UserPainting.texture = imageData;
 
func _physics_process(delta):
	if (visible and Input.is_action_just_pressed("interact")):
		swipePainting();

func showPainting(selectedPainting: int):
	displayedImageId = selectedPainting;
	$AnimationPlayer.play("RESET");
	visible = true;
	$Originals/Cena.visible = false;
	$Originals/Clocks.visible = false;
	$Originals/Monalisa.visible = false;
	$Originals/Pixels.visible = false;
	$Originals/Scream.visible = false;
	$Originals/Sky.visible = false;
	$Originals/Vah.visible = false;
	$Originals/Blue.visible = false;
	
	var paintingName = "";
	match (selectedPainting):
		Paintings.BLUE:
			$Originals/Blue.visible = true;
			paintingName = "Girl with a Pearl Earring";
			displayedImage = $Originals/Blue;
		Paintings.CLOCKS:
			$Originals/Clocks.visible = true;
			paintingName = "The Persistence of Memory";
			displayedImage = $Originals/Clocks;
		Paintings.MONALISA:
			$Originals/Monalisa.visible = true;
			paintingName = "Mona Lisa";
			$Fake/UserPainting.transform = $Originals/Monalisa.transform;
			displayedImage = $Originals/Monalisa;
		Paintings.PIXELS:
			$Originals/Pixels.visible = true;
			displayedImage = $Originals/Pixels;
			paintingName = "No. 5, 1948";
		Paintings.SCREAM:
			$Originals/Scream.visible = true;
			displayedImage = $Originals/Scream;
			paintingName = "The Scream";
		Paintings.SKY:
			$Originals/Sky.visible = true;
			displayedImage = $Originals/Sky;
			paintingName = "Starry Night";
		Paintings.CENA:
			$Originals/Cena.visible = true;
			displayedImage = $Originals/Cena;
			paintingName = "The Last Supper";
		Paintings.VAH:
			$Originals/Vah.visible = true;
			paintingName = "Portrait de L’artiste Sans Barbe";
	$Fake/UserPainting.scale = Vector2($Fake/UserPainting.scale.x, -$Fake/UserPainting.scale.y);
	$PaintingTitle.text = paintingName;
