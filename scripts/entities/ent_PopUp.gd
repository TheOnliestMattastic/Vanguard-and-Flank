extends Control
class_name PopUp

const MAIN_MENU = "res://scenes/main_menu.tscn"

func _ready() -> void:
	EventBus.button_pressed.connect(_on_button_pressed)

func _on_button_pressed(btn_name: String) -> void:
	match btn_name:
		"Main Menu": get_tree().change_scene_to_file(MAIN_MENU)
		"Quit": get_tree().quit()
