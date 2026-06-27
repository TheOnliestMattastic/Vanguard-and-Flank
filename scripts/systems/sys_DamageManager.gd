extends RefCounted
class_name DamageManager

enum RollState { Disadvantage, Neutral, Advantage }

const MATCHUPS: Dictionary = {
	"Slash": { "strong": ["Bash"], "weak": ["Pierce"] },
	"Bash": { "strong": ["Pierce"], "weak": ["Slash"] },
	"Pierce": { "strong": ["Slash"], "weak": ["Bash"] },
	"Fire": { "strong": ["Earth"], "weak": ["Water"] },
	"Earth": { "strong": ["Water"], "weak": ["Fire"] },
	"Water": { "strong": ["Fire"], "weak": ["Earth"] },
	"Life": { "strong": ["Space"], "weak": ["Life"] },
	"Space": { "strong": ["Life"], "weak": ["Space"] }
}

static func get_matchup(attacker_type: String, defender_type: String) -> RollState:
	var rules: Dictionary = MATCHUPS[attacker_type]
	if defender_type in rules.strong: return RollState.Advantage
	elif defender_type in rules.weak: return RollState.Disadvantage
	return RollState.Neutral
