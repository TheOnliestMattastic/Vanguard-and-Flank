extends Node2D
class_name CombatManager

@onready var game_master: GameMaster = $".."
const EVASION: int = 10

static func roll_for_init(queue: Array[Actor]) -> void:
	for actor in queue: 
		Manifest.combatants[actor]["init"] = Dice.roll_d20() + actor.data.spd
		Manifest.combatants[actor]["AP"] = min((Manifest.combatants[actor]["AP"] + 3), 5)
	queue.sort_custom(func(a, b): return Manifest.combatants[a]["init"] > Manifest.combatants[b]["init"])

static func has_ap(actor: Actor, ammount: int = 1) -> bool:
	return Manifest.combatants[actor]["AP"] >= ammount

static func spend_ap(actor: Actor, ammount: int = 1) -> void:
	if has_ap(actor, ammount): Manifest.combatants[actor]["AP"] = Manifest.combatants[actor]["AP"] - ammount
	else: print("[I AM ERROR] spend_ap edge case was activated!")

static func roll_for_attack(attacker: Actor, defender: Actor) -> Dictionary:
	var results: Dictionary
	var hit_modifier = attacker.data.pwr
	var evasion_modifier = defender.data.dex
	var hit_roll = Dice.roll_d20() + hit_modifier
	var dc = EVASION + evasion_modifier
	
	results["success"] = hit_roll >= dc
	results["attacker"] = attacker
	results["defender"] = defender
	results["hit"] = hit_roll
	results["dc"] = dc
	
	return results

func apply_damage(actor: Actor, ammount: int = 1) -> void:
	var hp = Manifest.combatants[actor]["HP"]
	var result = hp - ammount
	if result > 0: Manifest.combatants[actor]["HP"] = result
	else: game_master.actor_defeated(actor)
