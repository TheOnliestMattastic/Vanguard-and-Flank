extends Node
class_name Grid

@export var tilesheet: Texture2D
@export var cell_scene: PackedScene
@onready var ui: UI = %UI

func create_map() -> void:
	for child in self.get_children():
		remove_child(child)
		child.queue_free()
	for x in Manifest.GRID_SIZE.x:
		for y in Manifest.GRID_SIZE.y:
			var cell := cell_scene.instantiate()
			add_child(cell)
	add_cells_to_dict()

func add_cells_to_dict() -> void:
	var cells = self.get_children()
	for i in range(cells.size()):
		var cell = cells[i]
		# calculate cell coords and add them to the dictionary
		var x = i % int(Manifest.GRID_SIZE.x)
		var y = i / Manifest.GRID_SIZE.x
		var coords = Vector2i(x, y)
		Manifest.gridmap[coords] = cell
		randomize_tile(cell)

func randomize_tile(tile):
	var tile_size = Cell.SIZE
	var sheet_cols = tilesheet.get_width() / tile_size.x
	var sheet_rows = tilesheet.get_height() / tile_size.y
	var random_x = randi() % int(sheet_cols)
	var random_y = randi() % int(sheet_rows)
	var random_tile_coords = Vector2i(random_x, random_y)
	if tile.has_method("set_tile"):
		tile.set_tile(tilesheet, tile_size, random_tile_coords)

static func toggle_obstacle(coords: Vector2i, is_solid: bool) -> void:
	Manifest.astar.set_point_solid(coords, is_solid)

static func obstruct_combatant_position(list) -> void:
	for combatant in list: 
		Grid.toggle_obstacle(combatant.position / Manifest.CELL_SIZE, true)

# === Highlighting ===
static func clear_highlights() -> void:
	for cell in Manifest.gridmap:
		Manifest.gridmap[cell].modulate = Color(1, 1, 1, 1)

static func highlight_cells(cells: Array, color: String = "green") -> void:
	var shade: Color
	match color:
		"green": shade = Color(0.6, 1.0, 0.6, 1.0)
		"red": shade = Color(1.0, 0.6, 0.6, 1.0)
		_: shade = Color(0.6, 1.0, 0.6, 1.0)
	for cell in cells:
		Manifest.gridmap[cell].modulate = shade

static func highlight_range(actor: Actor, limit: int, color: String = "green", include_actors: bool = false, is_friendly: bool = false) -> void:
	var in_range: Array = get_cells_in_range(actor, limit)
	highlight_cells(in_range, color)
	if include_actors:
		var targets: Array = get_targets_in_range(actor, limit, is_friendly)
		highlight_cells(targets, color)

# === Grabbing cells ===
static func get_targets_in_range(actor: Actor, limit: int, is_friendly: bool = false) -> Array:
	var origin = actor.position / Manifest.CELL_SIZE
	var targets: Array[Vector2i] = []
	var alignment = actor.get_parent()
	
	for x in range(-limit, limit + 1):
		for y in range(-limit, limit + 1):
			var distance = abs(x) + abs(y)
			if distance == 0 or distance > limit: continue
			var target_pos: Vector2i = origin + Vector2(x, y)
			if not Manifest.astar.is_in_bounds(target_pos.x, target_pos.y): continue
			if not Manifest.astar.is_point_solid(target_pos): continue
			var target = Manifest.gridmap.get(target_pos).occupant
			if target:
				var same_team = (alignment == target.get_parent())
				if is_friendly == same_team: targets.append(target_pos)
	return targets

static func get_cells_in_range(actor: Actor, limit: int, astar: AStarGrid2D = Manifest.astar) -> Array:
	var start_pos = actor.position / Manifest.CELL_SIZE
	var cells = []
	
	toggle_obstacle(start_pos, false)
	for x in astar.region.size.x:
		for y in astar.region.size.y:
			var cell := Vector2i(x,y)
			var path = astar.get_id_path(start_pos, cell)
			if path.size() > 0 and path.size() - 1 <= limit and not astar.is_point_solid(cell): cells.append(cell)
	toggle_obstacle(start_pos, true) # reset starting cell as unwalkable
	return cells

static func find_path(start: Vector2, end: Vector2) -> Array:
	toggle_obstacle(start, false)
	var path = Manifest.astar.get_id_path(start, end)
	toggle_obstacle(start, true)
	return path

func move_actor(mover: Actor, target_pos: Vector2i, path: Array) -> void:
	var start_pos = Vector2i(mover.position / Manifest.CELL_SIZE)
	
	toggle_obstacle(start_pos, false)
	for cell in path:
		var target = Vector2(cell) * Manifest.CELL_SIZE
		var tween = create_tween()
		tween.tween_property(mover, "position", target, 0.2)
		await tween.finished
	
	toggle_obstacle(target_pos, true)
	Manifest.gridmap.get(target_pos).occupant = mover
	Manifest.gridmap.get(start_pos).occupant = null
