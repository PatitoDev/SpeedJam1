extends KinematicBody2D

var MAX_SPEED = 400
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
		
		var navigationArray = navigationAgent.get_nav_path();
		var rotationTarget;
		if (navigationArray.size() >= 5):
			rotationTarget = navigationArray[4];
		else:
			rotationTarget = navigationAgent.get_next_location();
		rotation_degrees = rad2deg(get_angle_to(rotationTarget) + rotation) + 90;
		
		hasArrived = navigationAgent.is_navigation_finished();
		if (hasCaptured()):
			get_tree().get_root().get_child(0).onDeath();
			

func apply_acceleration(acceleration: Vector2):
	velocity.x = move_toward(velocity.x, MAX_SPEED * acceleration.x, ACCELERATION);
	velocity.y = move_toward(velocity.y, MAX_SPEED * acceleration.y, ACCELERATION);

func hasCaptured():
	return position.distance_to(target.position) < 100;

var hasPlayedShout = false;

func _on_VisibilityArea_body_entered(body: Node2D):
	if (!hasArrived):
		get_tree().get_root().get_child(0).onChase();
		hasArrived = false;
		target = body;
		navigationAgent.set_target_location(target.position);
		if (!hasPlayedShout):
			hasPlayedShout = true;
			$AudioStreamPlayer.play(0);

func _on_NavigationAgent2D_velocity_computed(safe_velocity):
	velocity = move_and_slide(safe_velocity);
