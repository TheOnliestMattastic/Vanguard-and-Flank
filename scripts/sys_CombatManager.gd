extends Node2D
class_name CombatManager

const EVASION: int = 10

func _ready() -> void:
	Event.actor_damaged.connect(apply_damage)

static func roll_for_init(queue: Array[Actor]) -> void:
	for actor in queue: 
		Manifest.combatants[actor]["init"] = Dice.roll_d20() + actor.data.spd
		Manifest.combatants[actor]["AP"] = min((Manifest.combatants[actor]["AP"] + 3), 5)
		actor.acted = false
	queue.sort_custom(func(a, b): return Manifest.combatants[a]["init"] > Manifest.combatants[b]["init"])

static func has_ap(actor: Actor, ammount: int = 1) -> bool:
	return Manifest.combatants[actor]["AP"] >= ammount

static func spend_ap(actor: Actor, ammount: int = 1) -> void:
	if has_ap(actor, ammount): Manifest.combatants[actor]["AP"] = Manifest.combatants[actor]["AP"] - ammount
	else: print("[I AM ERROR] spend_ap edge case was activated!")

static func roll_for_attack(attacker: Actor, defender: Actor) -> Dictionary:
	var results: Dictionary
	var hit_result = Dice.roll_d20() + attacker.data.pwr
	var dc = EVASION + defender.data.dex
	results["success"] = hit_result >= dc
	results["attacker"] = attacker
	results["defender"] = defender
	results["hit"] = hit_result
	results["dc"] = dc
	return results

static func apply_damage(actor: Actor, ammount: int = 1) -> void:
	var hp = Manifest.combatants[actor]["HP"]
	var result = hp - ammount
	if result > 0: Manifest.combatants[actor]["HP"] = result
	else: Event.actor_defeated.emit(actor)

static func apply_heal(actor: Actor, ammount: int = 1) -> void:
	var hp = Manifest.combatants[actor]["HP"]
	var result = hp + ammount
	if result > actor.data.max_hp: Manifest.combatants[actor]["HP"] = actor.data.max_hp
	else: Manifest.combatants[actor]["HP"] = result
