extends Area2D

var speed : int = 150
var direction : Vector2
var player

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().root.get_node("Game/Player")  # Replace with the actual path to your player node

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player != null:
		look_at(player.global_position)  # Make the bullet face towards the player
		position += speed * direction.rotated(rotation) * delta  # Move the bullet in the direction it's facing

func _on_timer_timeout():
	queue_free() 

func _on_body_entered(body):
	print(body.name)
	if body.has_method("take_damage") and body.name == "Player":
		body.take_damage(1)  # Adjust damage amount as needed
