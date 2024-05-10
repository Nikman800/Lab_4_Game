extends TextureProgressBar

@onready var player = %Player


func _ready():
	#player.healthChanged.connect(update())
	player.healthChanged.connect(self.update)  # Pass the function itself

func update():
	value = player.current_health * 100 / player.max_health
	
