extends TextureRect
class_name Portrait

@onready var health: Health = %Health

func add_status_icon(icon: Texture2D) -> void:
	var status_grid: StatusGrid = %StatusGrid
	status_grid.add_icon(icon)
