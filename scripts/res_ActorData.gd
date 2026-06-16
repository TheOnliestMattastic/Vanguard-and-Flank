extends Resource
class_name ActorData

@export_group("ID")
@export var name: String = "Hero"
@export var spritesheet: Texture2D
@export var faceset: Texture2D
@export_enum("Vanguard", "Flank") var alignment: String
@export_enum("Damage Dealer", "Defender", "Healer", "Saboteur") var role: String

@export_group("Stats")
@export var max_hp: int = 3
@export var pwr: int = 5
@export var dex: int = 5
@export var spd: int = 3
@export var rng: int = 1

@export_group("Traits")
@export_enum("Slash", "Pierce", "Bash", "Fire", "Water", "Earth", "Life", "Space") var damage_type: String
@export var abilities: Array[AbilityData]
