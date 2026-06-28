extends Resource
class_name ActorData

enum Role { DAMAGE_DEALER, DEFENDER, HEALER, SABOTEUR }

@export_group("ID")
@export var name: String = "Hero"
@export var spritesheet: Texture2D
@export var faceset: Texture2D
@export var role: Role

@export_group("Traits")
@export var type: DamageManager.Type
@export var abilities: Array[AbilityData]

@export_group("Stats")
@export var max_hp: int = 3
@export var pwr: int = 5
@export var dex: int = 5
@export var spd: int = 3
@export var rng: int = 1
