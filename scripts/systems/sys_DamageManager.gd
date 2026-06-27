extends RefCounted
class_name DamageManager

enum Type { SLASH, BASH, PIERCE, FIRE, WATER, EARTH, LIFE, SPACE }
enum RollState { DISADVANTAGE = -1, NEUTRAL = 0, ADVANTAGE = 1 }

const MATCHUPS: Dictionary = {
	Type.SLASH: { "strong": [Type.BASH], "weak": [Type.PIERCE] },
	Type.BASH: { "strong": [Type.PIERCE], "weak": [Type.SLASH] },
	Type.PIERCE: { "strong": [Type.SLASH], "weak": [Type.BASH] },
	Type.FIRE: { "strong": [Type.EARTH], "weak": [Type.WATER] },
	Type.EARTH: { "strong": [Type.WATER], "weak": [Type.FIRE] },
	Type.WATER: { "strong": [Type.FIRE], "weak": [Type.EARTH] },
	Type.LIFE: { "strong": [Type.SPACE], "weak": [Type.LIFE] },
	Type.SPACE: { "strong": [Type.LIFE], "weak": [Type.SPACE] }
}

static func get_matchup(attacker: Type, defender: Type) -> RollState:
	var rules: Dictionary = MATCHUPS[attacker]
	if defender in rules.strong: return RollState.ADVANTAGE
	elif defender in rules.weak: return RollState.DISADVANTAGE
	return RollState.NEUTRAL
