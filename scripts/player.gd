extends CharacterBody2D

@onready var timer = $Timer
@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_area = $AttackArea
@onready var running_sound = $RunningSound


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
var took_damage = false

#Attack variables:
var is_attacking = false

signal healthChanged
signal dashChanged

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")



func take_damage(amount):
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	took_damage = true #Used to play animation for taking damage
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
		
func attack():
	if not is_attacking:  # Prevent attacking while already attacking
		is_attacking = true
		attack_area.monitoring = true
		
		

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

	# Regenerate boost if grounded and not full
	if is_grounded and current_boost < max_boost:
		current_boost += boost_regen_rate * delta
		current_boost = clamp(current_boost, 0.0, max_boost)
		
	# Emit dashChanged signal ONLY if boost has changed significantly
	if abs(current_boost - previous_boost) >= 0.1:  # Adjust the threshold as needed
		dashChanged.emit(current_boost) 
		#print(current_boost)
		
	#Attack code
	if Input.is_action_pressed("attack"):
		print("Player Attacking...")
		attack()
		
	
	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction > 0:
		animated_sprite.flip_h = false
		attack_area.scale.x = 1 # Flipped scale (facing right)
	elif direction < 0:
		animated_sprite.flip_h = true
		attack_area.scale.x = -1 # Flipped scale (facing left)
	
	#Play animations
	if is_attacking:
		animated_sprite.play("attack")
	elif took_damage:
		animated_sprite.play("damage")
		took_damage = false
	elif is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
	
	
	#Play SFX
	if is_on_floor() and direction != 0 and not running_sound.playing:
		running_sound.play()
	elif direction == 0 or not is_on_floor():
		running_sound.stop()
	
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()



func _on_timer_timeout():
	Engine.time_scale = 1.0
	#get_tree().reload_current_scene()
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")
	
func _ready():
	healthChanged.emit()
	dashChanged.emit(current_boost)
	



func _on_animated_sprite_2d_animation_finished():
	if animated_sprite.animation == "attack":
		is_attacking = false
		attack_area.monitoring = false  # Disable the hitbox


func _on_attack_area_area_entered(area):
	print("Area entered: " + area.name + ", is in 'enemy' group: " + str(area.is_in_group("enemy")))
	if area.is_in_group("enemy"):  # Assuming enemies are in the "enemy" group
		var enemy = area.get_parent()
		print("Enemy has been hit!!")
		enemy.take_damage(1)  # Apply damage to the enemy
