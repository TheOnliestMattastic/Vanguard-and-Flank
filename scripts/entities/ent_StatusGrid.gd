extends GridContainer
class_name StatusGrid

var status_icon_scene = preload("uid://d2wf8beqj1rd7")

func add_icon(icon: Texture2D, status_name: String) -> void:
	var status_icon = status_icon_scene.instantiate()
	status_icon.texture = icon
	status_icon.name = status_name
	add_child(status_icon)

func remove_icon(status_name: String) -> void:
	for child in get_children():
		if child.name == status_name:
			child.queue_free()
