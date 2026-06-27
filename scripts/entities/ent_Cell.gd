extends BaseButton
class_name Cell

@onready var texture_rect: TextureRect = $TextureRect
const SIZE: Vector2 = Vector2(32, 32)
var occupant: Actor = null

func set_tile(sheet: Texture2D, tile_size: Vector2i, coords: Vector2i):
	var atlas = AtlasTexture.new()
	atlas.atlas = sheet
	# Define which 32x32 area to show
	atlas.region = Rect2(coords.x * tile_size.x, coords.y * tile_size.y, tile_size.x, tile_size.y)
	texture_rect.texture = atlas

func _on_pressed() -> void:
	EventBus.cell_pressed.emit(self.position / Manifest.CELL_SIZE)
