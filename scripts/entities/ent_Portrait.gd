extends TextureRect
class_name Portrait

var status_grid: StatusGrid 
func get_status_grid() -> StatusGrid:
	if status_grid == null: status_grid = get_node("%StatusGrid")
	return status_grid

func add_status_icon(icon: Texture2D, status_name: String) -> void:
	get_status_grid().add_icon(icon, status_name)

func remove_status_icon(status_name: String) -> void:
	get_status_grid().remove_icon(status_name)
