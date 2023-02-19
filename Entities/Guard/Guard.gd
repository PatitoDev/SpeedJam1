extends KinematicBody2D

var MAX_SPEED = 500
var ACCELERATION = 100

var FRICTION = 100

var velocity = Vector2.ZERO;
onready var navigationAgent = $NavigationAgent2D;
var target = null;
var hasArrived = false;

func _physics_process(delta):
	if (target != null && !hasArrived):
		navigationAgent.set_target_location(target.position);
		var move_direction = position.direction_to(navigationAgent.get_next_location());
		velocity = move_direction * MAX_SPEED;
		navigationAgent.set_velocity(velocity);
		move_and_slide(velocity);
		
		rotation_degrees = rad2deg(get_angle_to(navigationAgent.get_next_location()) + rotation) ;
		
		hasArrived = navigationAgent.is_navigation_finished();
		if (hasCaptured()):
			get_tree().change_scene("res://Scenes/GameOver/GameOver.tscn");

func apply_acceleration(acceleration: Vector2):
	velocity.x = move_toward(velocity.x, MAX_SPEED * acceleration.x, ACCELERATION);
	velocity.y = move_toward(velocity.y, MAX_SPEED * acceleration.y, ACCELERATION);

func hasCaptured():
	return position.distance_to(target.position) < 100;

func _on_VisibilityArea_body_entered(body: Node2D):
	if (!hasArrived):
		hasArrived = false;
		target = body;
		navigationAgent.set_target_location(target.position);

func _on_NavigationAgent2D_velocity_computed(safe_velocity):
	velocity = move_and_slide(safe_velocity);
