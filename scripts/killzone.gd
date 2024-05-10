extends Area2D

@onready var timer = $Timer

func _on_body_entered(body):
	body.get_node("CollisionShape2D").queue_free()
	timer.start()
	


