extends Area2D

var speed : int = 150
var direction : Vector2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += speed * direction * delta
	



func _on_timer_timeout():
	queue_free() 
	



func _on_body_entered(body):
	#print(body.name)
	if body.has_method("take_damage") and body.name == "Player":
		body.take_damage(1)  # Adjust damage amount as needed
