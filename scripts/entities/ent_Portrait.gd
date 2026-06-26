extends TextureRect
class_name Portrait

@onready var health: Health = %Health

func add_status_icon(icon: Texture2D, status_name: String) -> void:
	var status_grid: StatusGrid = %StatusGrid
	status_grid.add_icon(icon, status_name)

func remove_status_icon(status_name: String) -> void:
	var status_grid: StatusGrid = %StatusGrid
	status_grid.remove_icon(status_name)
