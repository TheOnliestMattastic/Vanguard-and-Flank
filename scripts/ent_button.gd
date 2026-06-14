extends Button

func _on_pressed() -> void:
	Event.button_pressed.emit(self.name)
