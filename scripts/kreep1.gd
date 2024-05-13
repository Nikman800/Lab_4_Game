extends CharacterBody2D

@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var ray_cast_down = $RayCastDown
@onready var animated_sprite = $AnimatedSprite2D

const SPEED = 60

var x_direction = -1
var y_direction = 0

var was_hitting_left_wall = false
var was_on_surface = false

func _ready():
	was_hitting_left_wall = ray_cast_left.is_colliding()
	was_on_surface = ray_cast_down.is_colliding()

func _physics_process(delta):
	# Check for collisions and handle rotations
	if !ray_cast_down.is_colliding() and was_on_surface: # Not touching a surface
		print("Rotating anticlockwise")
		if x_direction == -1 and y_direction == 0:
			#self.rotation_degrees = -90
			rotate(deg_to_rad(-90))  # Rotate 90 degrees anticlockwise
			x_direction = 0
			y_direction = 1
		elif x_direction == 0 and y_direction == 1:
			#self.rotation_degrees = -90
			rotate(deg_to_rad(-90))  # Rotate 90 degrees anticlockwise
			x_direction = 1
			y_direction = 0
		elif x_direction == 1 and y_direction == 0:
			print("Rotating going up")
			#self.rotation_degrees = -90
			rotate(deg_to_rad(-90))  # Rotate 90 degrees anticlockwise
			x_direction = 0
			y_direction = -1
		elif x_direction == 0 and y_direction == -1:
			#self.rotation_degrees = -90
			rotate(deg_to_rad(-90))  # Rotate 90 degrees anticlockwise
			x_direction = -1
			y_direction = 0
	elif ray_cast_left.is_colliding() and not was_hitting_left_wall:  # Hitting left wall
		print("Rotating clockwise")
		if x_direction == -1 and y_direction == 0:
			rotate(deg_to_rad(90))
			x_direction = 0
			y_direction = -1
			position.x -= 3
		elif x_direction == 0 and y_direction == -1:
			rotate(deg_to_rad(90))  # Rotate 90 degrees anticlockwise
			x_direction = 1
			y_direction = 0
			position.y -= 3
		elif x_direction == 1 and y_direction == 0:
			rotate(deg_to_rad(90))  # Rotate 90 degrees anticlockwise
			x_direction = 0
			y_direction = 1
			position.x += 3
		elif x_direction == 0 and y_direction == 1:
			rotate(deg_to_rad(90))  # Rotate 90 degrees anticlockwise
			x_direction = -1
			y_direction = 0
			position.y += 3
		

	# Delay movement after rotation
	#if !was_on_surface or !was_hitting_left_wall:
		#await get_tree().process_frame  # Wait for one frame
		
	# Set the velocity based on direction
	velocity.x = SPEED * x_direction
	velocity.y = SPEED * y_direction

	# Move the enemy
	move_and_slide()
		
	# Store the previous state to detect changes
	was_hitting_left_wall = ray_cast_left.is_colliding()
	was_on_surface = ray_cast_down.is_colliding()  # Use raycast for surface detection
	#print("Colliding is " + str(was_on_surface))
