extends Control
class_name MainMenu

const GAME = preload("uid://d4mwir6knxacb")

func _ready() -> void:
	Event.button_pressed.connect(_on_button_pressed)

func _on_button_pressed(btn_name: String) -> void:
	match btn_name:
		"Play": get_tree().change_scene_to_packed(GAME)
		"Quit": get_tree().quit()
