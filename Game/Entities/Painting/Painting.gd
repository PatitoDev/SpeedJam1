extends Node2D

class_name Painting

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

export var selectedPainting = Paintings.BLUE;

func _ready():
	updatePainting();

func updatePainting():
	$Paintings/Bluegirl.visible = false;
	$Paintings/Clocks.visible = false;
	$Paintings/Monalisa.visible = false;
	$Paintings/Pixels.visible = false;
	$Paintings/Scream.visible = false;
	$Paintings/Sky.visible = false;
	$Paintings/Ultimacena.visible = false;
	$Paintings/Vahog.visible = false;
	
	match (selectedPainting):
		Paintings.BLUE:
			$Paintings/Bluegirl.visible = true;
		Paintings.CLOCKS:
			$Paintings/Clocks.visible = true;
		Paintings.MONALISA:
			$Paintings/Monalisa.visible = true;
		Paintings.PIXELS:
			$Paintings/Pixels.visible = true;
		Paintings.SCREAM:
			$Paintings/Scream.visible = true;
		Paintings.SKY:
			$Paintings/Sky.visible = true;
		Paintings.CENA:
			$Paintings/Ultimacena.visible = true;
		Paintings.VAH:
			$Paintings/Vahog.visible = true;
