extends TextureRect
class_name Portrait

var actor: ActorData

# === Health ===
var health: Health
func get_health() -> Health:
	if health == null: health = get_node("%Health")
	return health

func set_actor_hp(maximum: int) -> void:
	get_health().set_hp(maximum)

func set_actor_current_hp(hp: float) -> void:
	get_health().set_current_hp(hp)

# === Status ===
var status_grid: StatusGrid 
func get_status_grid() -> StatusGrid:
	if status_grid == null: status_grid = get_node("%StatusGrid")
	return status_grid

func add_status_icon(icon: Texture2D, status_name: String) -> void:
	get_status_grid().add_icon(icon, status_name)

func remove_status_icon(status_name: String) -> void:
	get_status_grid().remove_icon(status_name)

# === Input ===
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			EventBus.portrait_pressed.emit(self)
