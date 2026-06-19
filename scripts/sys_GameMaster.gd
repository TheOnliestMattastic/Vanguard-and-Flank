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

func  _on_button_pressed(btn_name: String):
	match btn_name:
		"Move": toggle_state(State.MOVE)
		"Attack": toggle_state(State.ATTACK)
		"Abilities": toggle_state(State.ABILITY)
		"Delay": delay_turn()
		"End": end_turn()
		"Main Menu": print("[I AM ERROR] Button not yet configured.")
		"Reset": print("[I AM ERROR] Button not yet configured.")

func _on_cell_pressed(coords: Vector2i):
	var active_actor = Manifest.queue[0]
	var pos = Vector2i(active_actor.position / Manifest.CELL_SIZE)
	
	match current_state:
		State.IDLE: 
			ui.log_to_banner("No action selected.")
		
		State.MOVE: 
			var path = Grid.find_path(pos, coords)
			var rate = round(active_actor.data.spd * SPD_MOD)
			var dist = path.size() - 1
			
			# exit if not within range
			if dist > int(rate * Manifest.combatants[active_actor]["AP"]): 
				ui.log_to_banner("Not fast enough for that...")
				return
			
			# exit if already occupied
			if Manifest.gridmap[coords].occupant: 
				ui.log_to_banner("Will not invade another's space...")
				return
			
			# exit if not enough ap
			var cost = round(dist / rate) 
			if not CombatManager.has_ap(active_actor, cost):
				ui.log_to_banner("Not enough AP...")
				return
			
			# spend ap and move actor
			CombatManager.spend_ap(active_actor, cost)
			grid.move_actor(active_actor, coords, path)
			active_actor.acted = true 
			toggle_state(State.IDLE)
		
		State.ATTACK:
			var target: Actor = Manifest.gridmap.get(coords).occupant
			
			# exit if not within range
			if int(pos.distance_to(coords)) > active_actor.data.rng:
				ui.log_to_banner("Too far...")
				return
			
			# exit if cell empty
			if not target: 
				ui.log_to_banner("Not a valid target...")
				return 
			
			# exit if friendly target
			if active_actor.data.alignment == target.data.alignment:
				ui.log_to_banner("Will not attack a friendly...")
				return
			
			# exit if not enough ap
			if not CombatManager.has_ap(active_actor):
				ui.log_to_banner("Not enough AP...")
				return
			
			if CombatManager.roll_for_attack(active_actor, target): 
				CombatManager.apply_damage(target)
			CombatManager.spend_ap(active_actor)
			active_actor.acted = true
			toggle_state(State.IDLE)
		
		State.ABILITY:
			var ability: AbilityData = active_actor.data.abilities[0]
			if not CombatManager.has_ap(active_actor, ability.ap_cost):
				ui.log_to_banner("Not enough ap...")
				return 
			
			# exit if not in range
			var distance = pos.distance_to(coords)
			if distance > ability.cast_range:
				ui.log_to_banner("Too far...")
				return
			
			# exit if invalid target
			var target: Actor = Manifest.gridmap.get(coords).occupant
			if not target:
				ui.log_to_banner("Not a valid target...")
				return
			
			var same_team = target.get_parent() == active_actor.get_parent()
			match ability.type:
				"Heal":
					if not same_team:
						ui.log_to_banner("Will only target friendlies...")
						return
					
					ability.execute(active_actor, coords)
				
				"Attack": 
					if same_team:
						ui.log_to_banner("Will not target friendlies...")
						return
					ability.execute(active_actor, coords)
					
			CombatManager.spend_ap(active_actor, ability.ap_cost)
			active_actor.acted = true
			toggle_state(State.IDLE)
		
		
		_: ui.log_to_banner("[I AM ERROR] Input configuration not yet configured!")

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
			var move_range = round(active_actor.data.spd * SPD_MOD) * Manifest.combatants[active_actor]["AP"]
			Grid.clear_highlights()
			Grid.highlight_range(Manifest.queue[0], move_range)
			ui.log_to_banner("Moving...")
		
		State.ATTACK:
			Grid.clear_highlights()
			Grid.highlight_range(Manifest.queue[0], active_actor.data.rng, "red", true)
			ui.log_to_banner("Attacking...")
		
		State.ABILITY:
			# FOR TESTING: need to refactor
			if not active_actor.data.abilities: return
			Grid.clear_highlights()
			active_actor.data.abilities[0].stage(active_actor)
			ui.log_to_banner("Choosing ability...")

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
	Manifest.queue[0].active = false
	Manifest.queue.pop_front()
	if Manifest.queue.size() == 0:
		var combatants = get_combatants()
		Manifest.queue.append_array(combatants)
		CombatManager.roll_for_init(Manifest.queue)
		ui.log_init()
	ui.display_queue(Manifest.queue)
	toggle_state(State.IDLE)

func delay_turn() -> void:
	if Manifest.queue[0].acted: 
		ui.log_to_banner("Already acted this round.")
	else:
		Manifest.queue[0].acted = true
		Manifest.queue[0].active = false
		Manifest.queue.push_back(Manifest.queue.pop_front())
		ui.display_queue(Manifest.queue)
		toggle_state(State.IDLE)
