extends Control
class_name Heart

const SPRITESHEET = preload("uid://8bjgmjln2gd3")
const SIZE := Vector2i(16,16)
const STEP: int = 64
@onready var texture_rect: TextureRect = $TextureRect

func fill(ammount: float = 1.0) -> void:
	var atlas = AtlasTexture.new()
	atlas.atlas = SPRITESHEET
	atlas.region = Rect2(ammount * STEP, 0, SIZE.x, SIZE.y)
	texture_rect.texture = atlas
