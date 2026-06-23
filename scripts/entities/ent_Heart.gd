@tool
extends TextureRect
class_name Heart

@export var spritesheet: AtlasTexture
const SIZE := Vector2i(16,16)
const MAX_HP: float = 1.0

func _ready() -> void:
	texture = spritesheet
	fill()

func fill(ammount: float = 1.0) -> void:
	var step: int = 64
	texture.region = Rect2(ammount * step, 0, SIZE.x, SIZE.y)
