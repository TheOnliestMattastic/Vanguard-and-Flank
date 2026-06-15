extends Resource
class_name AbilityData

@export var name: String = "Unknown Ability"
@export_multiline var description: String = ""
@export var ap_cost: int = 1
@export var cast_range: int = 1
@export var pwr_mod: float = 1
@export_enum("Attack", "Buff", "Debuff", "Heal") var type: String

func stage(caster: Actor) -> void: 
	return print("[I AM ERROR] Stage method not overridden for " + name + "!")

func execute(caster: Actor, coords: Vector2i) -> Dictionary:
	var results: Dictionary
	results["success"] = false
	results["message"] = "[I AM ERROR] Execute method not overridden for " + name + "!"
	return results
