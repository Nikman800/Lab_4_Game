extends CharacterBody2D

@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var ray_cast_down = $RayCastDown
@onready var animated_sprite = $AnimatedSprite2D
@onready var timer = $Timer


const SPEED = 60

var x_direction = -1
var y_direction = 0

var was_hitting_left_wall = false
var was_on_surface = false

#Health bar variables:
var max_health = 1
var current_health = max_health  # Initialize with full health

#shooting variables:
var player
var bullet_direction
var shooting_distance = 200
var can_shoot = true

#Signals
signal healthChanged
signal shoot

func take_damage(amount):
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	healthChanged.emit()
	#emit_signal("healthChanged", current_health)  # Notify about health change
	print("health is now " + str(current_health))

	if current_health <= 0:
		# Handle enemy death (e.g., game over, respawn)
		print("Enemy has died!")  # Replace with your death logic
		# Get and queue the CollisionShape2D for deletion
		var collision_shape = get_node("CollisionShape2D")  # Assuming it's a direct child
		collision_shape.queue_free()

func shoot_at_player(position, dir):
	print("Shooting at player")
	shoot.emit(position, dir)
	can_shoot = false
	

func _ready():
	healthChanged.emit()
	was_hitting_left_wall = ray_cast_left.is_colliding()
	was_on_surface = ray_cast_down.is_colliding()
	player = get_node("../Player")

func _physics_process(delta):
	# Check for collisions and handle rotations
	if !ray_cast_down.is_colliding() and was_on_surface: # Not touching a surface
		#print("Rotating anticlockwise")
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
			#print("Rotating going up")
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
		#print("Rotating clockwise")
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
		
		
	# Set the velocity based on direction
	velocity.x = SPEED * x_direction
	velocity.y = SPEED * y_direction

	# Move the enemy
	move_and_slide()
	
	#Implement Shooting logic
	#print(player.position)
	#print(position.distance_to(player.position))
	if position.distance_to(player.position) <= shooting_distance and can_shoot:
		bullet_direction = (player.position - position).normalized()
		timer.start()
		#can_shoot = false
		shoot_at_player(self.position, bullet_direction)
		
	# Store the previous state to detect changes
	was_hitting_left_wall = ray_cast_left.is_colliding()
	was_on_surface = ray_cast_down.is_colliding()  # Use raycast for surface detection
	#print("Colliding is " + str(was_on_surface))


func _on_timer_timeout():
	can_shoot = true
