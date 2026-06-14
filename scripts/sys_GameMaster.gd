extends Node2D
class_name GameMaster

enum State {
	IDLE,
	MOVE,
	ATTACK,
	ABILITY
}
var current_state: State

func _ready() -> void:
	Event.cell_pressed.connect(_on_cell_pressed)
	Event.button_pressed.connect(_on_button_pressed)

func _on_cell_pressed(coords: Vector2i):
	print(coords)

func  _on_button_pressed(btn_name: String):
	print(btn_name)
