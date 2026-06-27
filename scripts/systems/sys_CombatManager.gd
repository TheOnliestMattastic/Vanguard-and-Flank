extends Node2D
class_name CombatManager

@onready var ui: UI = %UI
@onready var game_master: GameMaster = %GameMaster

const EVASION_BASE: int = 10
enum DoT {
	Poison,
	Frostbite,
	Burn
}

func _ready() -> void:
	Event.actor_damaged.connect(apply_damage)
	Event.actor_healed.connect(apply_heal)
	Event.actor_doted.connect(apply_dot)
	Event.new_round.connect(_on_new_round)
	Event.new_turn.connect(_on_new_turn)

static func roll_for_init(queue: Array[Actor]) -> void:
	for actor in queue: 
		Manifest.combatants[actor]["init"] = Dice.roll_d20() + actor.data.spd
		Manifest.combatants[actor]["AP"] = min((Manifest.combatants[actor]["AP"] + 3), 5)
		actor.acted = false
	queue.sort_custom(func(a, b): return Manifest.combatants[a]["init"] > Manifest.combatants[b]["init"])
	Event.init_rolled.emit()

static func has_ap(actor: Actor, amount: int = 1) -> bool:
	return Manifest.combatants[actor]["AP"] >= amount

static func spend_ap(actor: Actor, amount: int = 1) -> void:
	if has_ap(actor, amount): Manifest.combatants[actor]["AP"] = Manifest.combatants[actor]["AP"] - amount
	else: print("[I AM ERROR] spend_ap edge case was activated!")

static func roll_for_attack(attacker: Actor, defender: Actor) -> bool:
	var result = Dice.roll_d20() + attacker.data.pwr
	var dc = EVASION_BASE + defender.data.dex
	Event.actor_attacked.emit(attacker, result, dc)
	return result >= dc

static func apply_damage(actor: Actor, amount: int = 1) -> void:
	var hp = Manifest.combatants[actor]["HP"]
	var result = clamp(hp - amount, 0, actor.data.max_hp)
	if result == 0: 
		Event.actor_defeated.emit(actor)
		return
	Manifest.combatants[actor]["HP"] = result
	Manifest.combatants[actor]["portrait"].set_actor_current_hp(result)

static func apply_heal(caster: Actor, target: Actor, amount: int = 1) -> void:
	var hp = Manifest.combatants[target]["HP"]
	var result = clamp(hp + amount, 0, target.data.max_hp)
	Manifest.combatants[target]["HP"] = result
	Manifest.combatants[target]["portrait"].set_actor_current_hp(result)

func apply_dot(actor: Actor, dot_name: String, icon: Texture2D, turns: int, amount: int = 1) -> void:
	Manifest.combatants[actor][dot_name] = { "turns": turns, "amount": amount, "icon": icon }
	Manifest.combatants[actor]["portrait"].add_status_icon(icon, dot_name)
	ui.display_queue(Manifest.queue)

func _on_new_turn() -> void:
	if Manifest.queue.size() == 0:
		game_master.new_round()
		return
	
	var active_actor: Actor = Manifest.queue[0]
	active_actor.active = true
	for type in DoT:
		if Manifest.has_component(active_actor, type):
			apply_damage(active_actor, Manifest.combatants[active_actor][type]["amount"])
			if not active_actor:
				if game_master.game_over(): 
					Event.game_over.emit(game_master.get_defeated_team().name)
					return
				Event.new_turn.emit()
				return 
			
			if Manifest.combatants[active_actor][type]["turns"] > 1: 
				Manifest.combatants[active_actor][type]["turns"] -= 1
			else: 
				Manifest.remove_component(active_actor, type)
				Manifest.combatants[active_actor]["portrait"].remove_status_icon(type)

static func _on_new_round() -> void:
	roll_for_init(Manifest.queue)
	Event.new_turn.emit()
