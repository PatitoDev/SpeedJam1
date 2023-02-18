extends KinematicBody2D

var MAX_SPEED = 500
var ACCELERATION = 100
var FRICTION = 100


var velocity = Vector2.ZERO;

func _process(delta):
	var input = Vector2.ZERO
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left");
	input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up");
	
	apply_acceleration(input);
	
	velocity = move_and_slide(velocity, Vector2.ZERO);

func apply_acceleration(acceleration: Vector2):
	velocity.x = move_toward(velocity.x, MAX_SPEED * acceleration.x, ACCELERATION);
	velocity.y = move_toward(velocity.y, MAX_SPEED * acceleration.y, ACCELERATION);
