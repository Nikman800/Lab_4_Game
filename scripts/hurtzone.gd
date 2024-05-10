extends Area2D

@onready var timer = $Timer

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(1)  # Adjust damage amount as needed
		
	
	
	


