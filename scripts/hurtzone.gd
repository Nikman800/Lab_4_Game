extends Area2D

@onready var timer = $Timer


func _on_body_entered(body):
	body.get_node("CollisionShape2D").currentHealth -= 1
	print(body.get_node("CollisionShape2D").currentHealth)
	if body.get_node("CollisionShape2D").currentHealth <= 0:
		print("You died!")
		Engine.time_scale = 0.5
		body.get_node("CollisionShape2D").queue_free()
		timer.start()
	
func _on_timer_timeout():
	Engine.time_scale = 1
	get_tree().reload_current_scene()
