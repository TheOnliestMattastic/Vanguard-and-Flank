extends Node2D
class_name GameMaster

@onready var vanguard: Node2D = %Vanguard
@onready var flank: Node2D = %Flank
@onready var ui: UI = %UI
@onready var grid: Grid = %Grid

const SPD_MOD = 0.5

enum State {
	IDLE,
	MOVE,
	ATTACK,
	ABILITY
}
var current_state: State

func _ready() -> void:
	Event.cell_pressed.connect(_on_cell_pressed)
	Event.button_pressed.connect(_on_button_pressed)
	Event.actor_defeated.connect(_on_actor_defeated)
	
	var combatants = get_combatants()
	Manifest.queue.append_array(combatants)
	Manifest.add_combatants(Manifest.queue)
	for combatant in Manifest.combatants: 
		Grid.toggle_obstacle(combatant.position / Manifest.CELL_SIZE, true)
	
	CombatManager.roll_for_init(Manifest.queue)
	ui.log_init()
	ui.display_queue(Manifest.queue)
	toggle_state(State.IDLE)

func _process(delta: float) -> void:
	ui.display_active(Manifest.queue[0])
	for combatant in Manifest.combatants:
		if combatant.target: ui.display_target(combatant)

func _on_cell_pressed(target_coords: Vector2i):
	var active_actor = Manifest.queue[0]
	var pos = Vector2i(active_actor.position / Manifest.CELL_SIZE)
	
	match current_state:
		State.IDLE: 
			ui.log_to_banner("No action selected.")
		
		State.MOVE: 
			Grid.toggle_obstacle(pos, false)
			var path = Grid.find_path(pos, target_coords)
			var rate = int(active_actor.data.spd * SPD_MOD)
			var limit = rate * Manifest.combatants[active_actor]["AP"]
			var dist = (path.size() - 1)
			
			# exit if not within range
			if dist > limit: 
				ui.log_to_banner("Not within range...")
				return
			
			# exit if not enough ap
			var cost = dist / rate 
			if not CombatManager.has_ap(active_actor, cost):
				ui.log_to_banner("Not enough AP...")
				return
			
			# spend ap and move actor
			CombatManager.spend_ap(active_actor, cost)
			grid.move_actor(active_actor, target_coords) 
			toggle_state(State.IDLE)
		
		State.ATTACK:
			var target = Manifest.gridmap.get(target_coords).occupant
			if not target: 
				ui.log_to_banner("No valid target.")
				return 
			
			if not CombatManager.has_ap(active_actor):
				ui.log_to_banner("Not enough AP.")
				return
			
			var results = CombatManager.roll_for_attack(active_actor, target)
			CombatManager.spend_ap(active_actor)
			CombatManager.apply_damage(target)
			ui.log_hit_results(results)
			toggle_state(State.IDLE)
		
		_: ui.log_to_banner("[I AM ERROR]: Input configuration not set!")

func  _on_button_pressed(btn_name: String):
	match btn_name:
		"moveButton": toggle_state(GameMaster.State.MOVE)
		"attackButton": toggle_state(GameMaster.State.ATTACK)
		"delayButton": delay_turn()
		"endButton": end_turn()
		_: toggle_state(GameMaster.State.IDLE)

func toggle_state(target_state: State) -> void:
	if current_state == target_state: current_state = State.IDLE
	else: current_state = target_state
	var active_actor = Manifest.queue[0]
	active_actor.active = true
	
	match current_state:
		State.IDLE:
			Grid.clear_highlights()
			ui.log_to_banner(active_actor.name + "'s turn...")
		
		State.MOVE:
			Grid.clear_highlights()
			Grid.highlight_range(Manifest.queue[0])
			ui.log_to_banner("Moving...")
		
		State.ATTACK:
			Grid.clear_highlights()
			Grid.highlight_range(Manifest.queue[0], "red")
			ui.log_to_banner("Attacking...")

func get_combatants() -> Array:
	var combatants: Array
	var v = vanguard.get_children()
	var f = flank.get_children()
	combatants.append_array(v)
	combatants.append_array(f)
	return combatants

func _on_actor_defeated(actor: Actor) -> void:
	var coords := Vector2i(actor.position / Manifest.CELL_SIZE)
	var alignment := actor.data.alignment
	Manifest.remove_from_queue(actor)
	actor.queue_free()
	Grid.toggle_obstacle(coords, false)
	ui.display_queue(Manifest.queue)
	
	# check for win condition
	# checking w/-1 because actor is queued for deletion but not yet deleted
	var team
	match alignment:
		vanguard.name: team = vanguard.get_child_count()
		flank.name: team = flank.get_child_count()
	if team - 1 == 0: Event.game_over.emit(alignment)

func end_turn() -> void:
	Manifest.queue.pop_front()
	if Manifest.queue.size() == 0:
		var combatants = get_combatants()
		Manifest.queue.append_array(combatants)
		CombatManager.roll_for_init(Manifest.queue)
		ui.log_init()
	ui.display_queue(Manifest.queue)
	toggle_state(State.IDLE)

func delay_turn() -> void:
	if Manifest.queue[0].delayed: 
		ui.log_to_banner("Turn already delayed this round.")
	else:
		Manifest.queue[0].delayed = true
		Manifest.queue.push_back(Manifest.queue.pop_front())
		ui.display_queue(Manifest.queue)
		toggle_state(State.IDLE)
