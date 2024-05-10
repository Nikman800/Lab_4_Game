extends TextureProgressBar

@onready var player = %Player


func _ready():
	if player != null:
		player.healthChanged.connect(self.update) 
		value = player.current_health * 100 / player.max_health  # Set initial value

func update():
	value = player.current_health * 100 / player.max_health
