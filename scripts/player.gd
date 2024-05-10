extends CharacterBody2D

@onready var timer = $Timer


const SPEED = 130.0
const JUMP_VELOCITY = -300.0

# Declare member variables
var dash_speed = 200 
var dash_time = 0.3  
var is_dashing = false
var dash_direction = Vector2.ZERO
var remaining_dash_time = 0.0

# Boost meter variables
var max_boost = 100.0
var current_boost = max_boost
var boost_regen_rate = 100.0  # Boost regeneration per second
var boost_cost = 30.0       # Boost consumed per dash

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
	
	# Regenerate boost if grounded and not full
	if is_grounded and current_boost < max_boost:
		current_boost += boost_regen_rate * delta
		current_boost = clamp(current_boost, 0.0, max_boost)
	
	dashChanged.emit()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	
	if Input.is_action_pressed("dash") and not is_dashing and current_boost >= boost_cost:
		# Initiate dash
		is_dashing = true
		remaining_dash_time = dash_time
		current_boost -= boost_cost
		
		# Get input direction (normalize for consistent speed)
		dash_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()

		# Set velocity directly for CharacterBody2D
		#self.velocity = dash_direction * dash_speed
		
	if is_dashing:
		# Update remaining dash time
		remaining_dash_time -= delta

		# Calculate movement for this frame
		velocity.y = 0  # Reset vertical velocity
		var motion = dash_direction * dash_speed * delta 

		# Move and collide
		move_and_collide(motion)

		# Allow player to influence trajectory during the dash
		var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if input_direction != Vector2.ZERO:
			dash_direction = dash_direction.lerp(input_direction.normalized(), 0.2)

		# End dash when time runs out
		if remaining_dash_time <= 0:
			is_dashing = false
			dash_direction = Vector2.ZERO
		
		dashChanged.emit()
			
	
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
	
	# Example: Taking damage from an Area2D with a CollisionShape2D
	#for area in has_overlapping_bodies():
		#if area.name == "DamageArea":
			#take_damage(1)  # Adjust damage amount as needed


func _on_timer_timeout():
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
	
func _ready():
	healthChanged.emit()
	dashChanged.emit()
	

