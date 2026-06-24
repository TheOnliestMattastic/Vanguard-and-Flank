extends GridContainer
class_name StatusGrid

var status_icon_scene = preload("uid://d2wf8beqj1rd7")

func _ready() -> void:
	Event.actor_doted.connect(add_icon)

func add_icon(actor: Actor, dot_name: String, icon: Texture2D, turns: int) -> void:
	var status_icon = status_icon_scene.instantiate()
	status_icon.texture = icon
	add_child(status_icon)
	print("add_icon")
