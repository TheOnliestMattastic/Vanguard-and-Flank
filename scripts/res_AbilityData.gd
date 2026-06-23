extends Resource
class_name AbilityData

@export var name: String = "Unknown Ability"
@export_multiline var description: String = ""
@export var ap_cost: int = 1
@export var cast_range: int = 1
@export var pwr_mod: float = 1
@export_enum("Attack", "Buff", "Debuff", "Heal") var type: String
@export_enum("Slash", "Pierce", "Bash", "Fire", "Water", "Earth", "Life", "Space") var damage_type: String
@export var icon: Texture

func stage(caster: Actor) -> void: 
	return print("[I AM ERROR] Stage method not overridden for " + name + "!")

func execute(caster: Actor, coords: Vector2i) -> bool:
	print("[I AM ERROR] Execute method not overridden for " + name + "!")
	return false
