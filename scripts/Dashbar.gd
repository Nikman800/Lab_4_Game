extends TextureProgressBar


@onready var player = %Player


func _ready():
	if player != null:
		player.dashChanged.connect(self.update_dash)  
		value = player.current_boost  # Set initial value

func update_dash():
	#value = new_boost
	value = player.current_boost * 100 / player.max_boost
