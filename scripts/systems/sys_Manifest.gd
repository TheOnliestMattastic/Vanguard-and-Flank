extends Node

# === Game board config ===
const GRID_SIZE: Vector2 = Vector2(12, 5)
const CELL_SIZE: Vector2 = Vector2(64, 64)
var gridmap: Dictionary
var astar := AStarGrid2D.new()

# === Actors config ===
enum Alignment { VANGUARD, FLANK }
const SQUAD_SIZE: int = 6
var roster_vanguard: Array[Portrait]
var roster_flank: Array[Portrait]
var combatants: Dictionary
var portraits: Dictionary
var queue: Array[Actor]

const PORTRAIT = preload("uid://dj5n66q8cooig")

func _init():
	astar.region = Rect2i(Vector2i.ZERO, GRID_SIZE)
	astar.cell_size = CELL_SIZE
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()

func add_combatants(actors: Array[Actor]) -> void:
	for actor in actors:
		combatants[actor] = {}
		combatants[actor]["hp"] = actor.data.max_hp
		combatants[actor]["ap"] = 0
		
		var coords = Vector2i(actor.position / CELL_SIZE)
		gridmap[coords].occupant = actor
		
		var portrait = PORTRAIT.instantiate()
		portrait.texture = actor.data.faceset
		portraits[portrait] = actor 
		combatants[actor]["portrait"] = portrait
		combatants[actor]["portrait"].set_actor_hp(actor.data.max_hp)

func append_roster(actor: Portrait, alignment: Alignment) -> void:
	var roster: Array[Portrait]
	match alignment:
		Alignment.VANGUARD:
			roster = roster_vanguard
		Alignment.FLANK:
			roster = roster_flank
	
	if roster.size() < SQUAD_SIZE:
		roster.append(actor)

func pop_roster(alignment: Alignment) -> void:
	var roster: Array[Portrait]
	match alignment:
		Alignment.VANGUARD:
			roster = roster_vanguard
		Alignment.FLANK:
			roster = roster_flank
	
	if not roster.is_empty():
		var last_unit: Portrait = roster.back()
		last_unit.disabled = false
		roster.erase(last_unit)

func remove_from_queue(actor: Actor) -> void:
	var coords = Vector2i(actor.position / CELL_SIZE)
	gridmap[coords].occupant = null
	combatants.erase(actor)
	for i in queue.size():
		if queue[i] == actor: 
			queue.pop_at(i)
			break

func has_component(actor: Actor, component: String) -> bool:
	return combatants[actor].has(component)

func remove_component(actor: Actor, component: String) -> void:
	if has_component(actor, component): 
		combatants[actor].erase(component)
	else: print("[I AM ERROR] Cannot find the following component on actor " + actor.name + ": " + component)
