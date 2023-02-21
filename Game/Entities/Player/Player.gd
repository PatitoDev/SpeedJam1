extends KinematicBody2D

var MAX_SPEED = 500
var ACCELERATION = 100
var FRICTION = 100

var velocity = Vector2.ZERO;
var interactiveItem;
var overlayShowing = false;

signal user_interacted_with_painting(selectedPainting)

func _physics_process(delta):
	var input = Vector2.ZERO
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left");
	input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up");
	apply_acceleration(input);
	velocity = move_and_slide(velocity, Vector2.ZERO);
	
	if input.x > 0:
		$Sprite.rotation_degrees = 90;
	elif input.x < 0:
		$Sprite.rotation_degrees = -90;
	elif input.y > 0:
		$Sprite.rotation_degrees = -180;
	elif input.y < 0:
		$Sprite.rotation_degrees = 0;
	
	if (interactiveItem != null and !overlayShowing):
		if (Input.is_action_just_pressed("ui_accept")):
			overlayShowing = true;
			print('opened paint');
			emit_signal('user_interacted_with_painting', interactiveItem);
			return;
	
	if (overlayShowing and (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_close"))):
		overlayShowing = false;
		self.get_parent().get_node("Camera2D/OpenedPaintingOverlay").visible = false;
			
func apply_acceleration(acceleration: Vector2):
	velocity.x = move_toward(velocity.x, MAX_SPEED * acceleration.x, ACCELERATION);
	velocity.y = move_toward(velocity.y, MAX_SPEED * acceleration.y, ACCELERATION);

func _on_DetectionArea_area_entered(area: Area2D):
	var objectToInteract = area.get_parent();
	print(objectToInteract.name);
	if (objectToInteract is Painting):
		interactiveItem = objectToInteract;

func _on_DetectionArea_area_exited(area):
	var objectToInteract = area.get_parent();
	if (interactiveItem == objectToInteract):
		interactiveItem = null;
