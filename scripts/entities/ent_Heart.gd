@tool
extends TextureRect
class_name Heart

const SIZE := Vector2i(16,16)

func fill(amount: float = 1) -> void:
	var step: int = 64
	texture.region = Rect2(amount * step, 0, SIZE.x, SIZE.y)
