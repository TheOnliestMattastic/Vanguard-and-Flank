extends RefCounted
class_name DamageManager

enum Type { SLASH, BASH, PIERCE, FIRE, WATER, EARTH, LIFE, SPACE }
enum RollState { DISADVANTAGE = -1, NEUTRUAL = 0, ADVANTAGE = 1 }

const MATCHUPS: Dictionary = {
	Type.SLASH: { "strong": [Type.BASH, Type.EARTH], "weak": [Type.PIERCE, Type.WATER] },
	Type.BASH: { "strong": [Type.PIERCE, Type.WATER], "weak": [Type.SLASH, Type.FIRE] },
	Type.PIERCE: { "strong": [Type.SLASH, Type.FIRE], "weak": [Type.BASH, Type.EARTH] },
	Type.FIRE: { "strong": [Type.EARTH, Type.BASH], "weak": [Type.WATER, Type.PIERCE] },
	Type.EARTH: { "strong": [Type.WATER, Type.PIERCE], "weak": [Type.FIRE, Type.SLASH] },
	Type.WATER: { "strong": [Type.FIRE, Type.SLASH], "weak": [Type.EARTH, Type.BASH] },
	Type.LIFE: { "strong": [Type.SPACE], "weak": [Type.LIFE] },
	Type.SPACE: { "strong": [Type.LIFE], "weak": [Type.SPACE] }
}

static func get_matchup(attacker_type: Type, defender_type: Type) -> RollState:
	var rules: Dictionary = MATCHUPS[attacker_type]
	if defender_type in rules.strong: return RollState.ADVANTAGE
	elif defender_type in rules.weak: return RollState.DISADVANTAGE
	return RollState.NEUTRUAL
