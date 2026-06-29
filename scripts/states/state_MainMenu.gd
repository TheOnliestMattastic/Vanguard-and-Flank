extends Control
class_name MainMenu

const GAME = "res://scenes/game.tscn"

func _ready() -> void:
	EventBus.button_pressed.connect(_on_button_pressed)

func _on_button_pressed(btn_name: String) -> void:
	match btn_name:
		"Play": get_tree().change_scene_to_file(GAME)
		"Quit": get_tree().quit()
