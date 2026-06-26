extends BoxContainer
class_name Health

var heart_scene: PackedScene = preload("uid://bexjftmwpo0cb")
const HEARTS_PER_ROW: int = 5
const HP_PER_HEART: int = 1
var max_hp: int 
var current_hp: float

func set_hp(maximum: int = 3) -> void:
	set_max_hp(maximum)
	set_current_hp(maximum)
	refresh_hearts()

func set_current_hp(ammount: float) -> void:
	current_hp = clamp(ammount, 0, max_hp)
	refresh_hearts()

func set_max_hp(maximum: int) -> void:
	max_hp = clamp(maximum, 1, HEARTS_PER_ROW)
	refresh_hearts()

func draw_hearts() -> void:
	var hearts: int = int(ceil(max_hp / HP_PER_HEART))
	for child in get_children():
		remove_child(child)
		child.free()
	for heart in hearts:
		var h = heart_scene.instantiate()
		add_child(h)

func fill_hearts() -> void:
	var current: float = current_hp
	for heart in get_children():
		var fill: float = clamp(current, 0, HP_PER_HEART)
		heart.fill(fill)
		current -= HP_PER_HEART

func refresh_hearts() -> void: 
	draw_hearts()
	fill_hearts()
