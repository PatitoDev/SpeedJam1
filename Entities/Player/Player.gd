extends KinematicBody2D

var MAX_SPEED = 500
var ACCELERATION = 100
var FRICTION = 100

var velocity = Vector2.ZERO;
var interactiveItem;

signal user_interacted_with_painting;

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
	
	
	if (interactiveItem != null):
		if (Input.is_action_just_pressed("ui_accept")):
			print('opened paint');
			emit_signal('user_interacted_with_painting');

func apply_acceleration(acceleration: Vector2):
	velocity.x = move_toward(velocity.x, MAX_SPEED * acceleration.x, ACCELERATION);
	velocity.y = move_toward(velocity.y, MAX_SPEED * acceleration.y, ACCELERATION);

func _on_DetectionArea_area_entered(area: Area2D):
	var objectToInteract = area.get_parent();
	match objectToInteract.name:
		'Painting':
			interactiveItem = objectToInteract;

func _on_DetectionArea_area_exited(area):
	var objectToInteract = area.get_parent();
	if (interactiveItem == objectToInteract):
		interactiveItem = null;
