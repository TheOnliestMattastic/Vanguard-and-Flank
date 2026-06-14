extends ScrollContainer

var max_scroll_length = 0

func _ready() -> void:
	var scrollbar = get_v_scroll_bar()
	scrollbar.changed.connect(_on_scrollbar_changed)
	max_scroll_length = scrollbar.max_value

# Push scroll bar to the bottom
func _on_scrollbar_changed():
	if max_scroll_length != get_v_scroll_bar().max_value:
		max_scroll_length = get_v_scroll_bar().max_value
		scroll_vertical = max_scroll_length
