extends GridContainer
class_name StatusGrid

var status_icon_scene = preload("uid://d2wf8beqj1rd7")

func add_icon(icon: Texture2D) -> void:
	var status_icon = status_icon_scene.instantiate()
	status_icon.texture = icon
	add_child(status_icon)
	print("add_icon")
