@tool
extends Button

func _ready() -> void:
	if not text.is_empty(): name = text

func _on_pressed() -> void:
	Event.button_pressed.emit(self.name)
