extends Node

# === Game board config ===
const GRID_SIZE: Vector2 = Vector2(12, 5)
const CELL_SIZE: Vector2 = Vector2(64, 64)
var gridmap: Dictionary
var astar := AStarGrid2D.new()

# === Actors config ===
var combatants: Dictionary
var portraits: Dictionary
var queue: Array[Actor]

func _init():
	astar.region = Rect2i(Vector2i.ZERO, GRID_SIZE)
	astar.cell_size = CELL_SIZE
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()

func add_combatants(actors: Array[Actor]) -> void:
	for actor in actors:
		var coords = Vector2i(actor.position / CELL_SIZE)
		gridmap[coords].occupant = actor
		combatants[actor] = {}
		combatants[actor]["HP"] = actor.data.max_hp
		combatants[actor]["AP"] = 0

func add_portrait(actor: Actor, portrait) -> void:
	portraits[portrait] = actor 

func remove_from_queue(actor: Actor) -> void:
	var coords = Vector2i(actor.position / CELL_SIZE)
	gridmap[coords].occupant = null
	combatants.erase(actor)
	for i in queue.size():
		if queue[i] == actor: 
			queue.pop_at(i)
			break

func add_component(actor: Actor, component: String, value) -> void:
	combatants[actor][component] = value
	return print(combatants[actor][component])

func has_component(actor: Actor, component: String) -> bool:
	if combatants[actor][component]: return true
	else: return false
