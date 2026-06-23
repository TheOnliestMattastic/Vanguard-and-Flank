extends GridContainer
class_name HealthBar

var heart_scene: PackedScene = preload("uid://dahbbyftluwts")
var hp_per_heart: float = 1.0
var current_hp: float = 3.0
var max_hp: float = 3.0

func _ready() -> void:
	rebuild_hearts()
	refresh()

func set_health(current: float, maximum: float) -> void:
	var has_changed = not is_equal_approx(maximum, max_hp)
	max_hp = maximum
	current_hp = current
	if has_changed: rebuild_hearts()
	refresh()

func set_current(current: float) -> void:
	current_hp = clamp(current, 0.0, max_hp)
	refresh()

func set_max(maximum: float) -> void:
	max_hp = max(maximum, 0.0)
	refresh()

func rebuild_hearts() -> void:
	var hearts: int = int(ceil(max_hp / hp_per_heart))
	while get_child_count() < hearts:
		var h := heart_scene.instantiate()
		h.hp_per_heart = hp_per_heart
		add_child(h)
	
	while get_child_count() > hearts:
		var child := get_child(get_child_count() - 1)
		remove_child(child)
		child.queue_free()

func refresh() -> void:
	var current: float = current_hp
	for i in get_child_count():
		var heart := get_child(i)
		var fill = clamp(current, 0.0, hp_per_heart)
		heart.fill(fill)
		current -= hp_per_heart
