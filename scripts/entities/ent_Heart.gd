extends TextureProgressBar
class_name Heart

@export var hp_per_heart: float = 1.0

func _ready() -> void:
	fill_mode = FILL_COUNTER_CLOCKWISE
	min_value = 0.0
	max_value = hp_per_heart
	step = 0.25
	value = hp_per_heart

func fill(hp: float) -> void:
	value = clamp(hp, 0.0, hp_per_heart)
