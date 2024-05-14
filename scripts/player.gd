extends CharacterBody2D

@onready var timer = $Timer


const SPEED = 130.0
const JUMP_VELOCITY = -300.0

# Declare member variables
var dash_speed = 175 
var dash_time = 0.3  
var is_dashing = false
var dash_direction = Vector2.ZERO
var remaining_dash_time = 0.0
var dash_depletion_rate = 100  # Adjust this value to control depletion speed

# Boost meter variables
var max_boost = 100.0
var current_boost = max_boost
var boost_regen_rate = 100.0  # Boost regeneration per second
#var boost_cost = 30.0       # Boost consumed per dash

#Health bar variables:
var max_health = 3
var current_health = max_health  # Initialize with full health

signal healthChanged
signal dashChanged

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D

func take_damage(amount):
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	healthChanged.emit()
	#emit_signal("healthChanged", current_health)  # Notify about health change
	print("health is now " + str(current_health))

	if current_health <= 0:
		# Handle player death (e.g., game over, respawn)
		print("Player has died!")  # Replace with your death logic
		Engine.time_scale = 0.5
		# Get and queue the CollisionShape2D for deletion
		var collision_shape = get_node("CollisionShape2D")  # Assuming it's a direct child
		collision_shape.queue_free()
		timer.start()
		

	
		

func _physics_process(delta):
	# Ground check
	var is_grounded = is_on_floor()
	
	#Store previous boost value
	var previous_boost = current_boost
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	
	# Dash Input Check
	if Input.is_action_pressed("dash") and current_boost > 0: 
		# Initiate dash ONLY when the button is pressed AND there's enough boost
		is_dashing = true
		dash_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
		dashChanged.emit(current_boost)  # Emit signal before deducting cost
		#current_boost -= dash_depletion_rate * delta # Deplete boost based on rate and delta time
		#current_boost -= boost_cost     # Deduct cost after emitting signal
	else:
		# Stop dashing if the button is released
		is_dashing = false
		
	if is_dashing: 
		# Apply dash movement
		velocity.y = 0 
		var motion = dash_direction * dash_speed * delta 
		move_and_collide(motion)

		# Allow player to influence trajectory
		var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if input_direction != Vector2.ZERO:
			dash_direction = dash_direction.lerp(input_direction.normalized(), 0.2)

		#current_boost -= 1  # Adjust how fast boost decreases
		current_boost -= dash_depletion_rate * delta # Deplete boost based on rate and delta time
		current_boost = clamp(current_boost, 0, max_boost)  # Clamp boost to zero

		#dashChanged.emit(current_boost) 

	# Regenerate boost if grounded and not full
	if is_grounded and current_boost < max_boost:
		current_boost += boost_regen_rate * delta
		current_boost = clamp(current_boost, 0.0, max_boost)
		
	# Emit dashChanged signal ONLY if boost has changed significantly
	if abs(current_boost - previous_boost) >= 0.1:  # Adjust the threshold as needed
		dashChanged.emit(current_boost) 
		#print(current_boost)
	
	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	#Play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
	
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func _on_timer_timeout():
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
	
func _ready():
	healthChanged.emit()
	dashChanged.emit(current_boost)
	

