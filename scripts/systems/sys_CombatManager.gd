extends Node2D
class_name CombatManager

const EVASION_BASE: int = 10

func _ready() -> void:
	Event.actor_damaged.connect(apply_damage)
	Event.actor_healed.connect(apply_heal)
	Event.actor_doted.connect(apply_dot)
	Event.new_round.connect(_on_new_round)

static func roll_for_init(queue: Array[Actor]) -> void:
	for actor in queue: 
		Manifest.combatants[actor]["init"] = Dice.roll_d20() + actor.data.spd
		Manifest.combatants[actor]["AP"] = min((Manifest.combatants[actor]["AP"] + 3), 5)
		actor.acted = false
	queue.sort_custom(func(a, b): return Manifest.combatants[a]["init"] > Manifest.combatants[b]["init"])
	Event.init_rolled.emit()

static func has_ap(actor: Actor, ammount: int = 1) -> bool:
	return Manifest.combatants[actor]["AP"] >= ammount

static func spend_ap(actor: Actor, ammount: int = 1) -> void:
	if has_ap(actor, ammount): Manifest.combatants[actor]["AP"] = Manifest.combatants[actor]["AP"] - ammount
	else: print("[I AM ERROR] spend_ap edge case was activated!")

static func roll_for_attack(attacker: Actor, defender: Actor) -> bool:
	var result = Dice.roll_d20() + attacker.data.pwr
	var dc = EVASION_BASE + defender.data.dex
	Event.actor_attacked.emit(attacker, result, dc)
	return result >= dc

static func apply_damage(actor: Actor, ammount: int = 1) -> void:
	var hp = Manifest.combatants[actor]["HP"]
	var result = hp - ammount
	if result > 0: Manifest.combatants[actor]["HP"] = result
	else: Event.actor_defeated.emit(actor)

static func apply_heal(caster: Actor, target: Actor, ammount: int = 1) -> void:
	var hp = Manifest.combatants[target]["HP"]
	var result = hp + ammount
	if result > target.data.max_hp: Manifest.combatants[target]["HP"] = target.data.max_hp
	else: Manifest.combatants[target]["HP"] = result

static func apply_dot(actor: Actor, dot_name: String, turns: int, ammount: int = 1) -> void: 
	var value: Dictionary = { "turns": turns, "ammount": ammount }
	Manifest.add_component(actor, dot_name, value)

static func _on_new_round() -> void:
	roll_for_init(Manifest.queue)
