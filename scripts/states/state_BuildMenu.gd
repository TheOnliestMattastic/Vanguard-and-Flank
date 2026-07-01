extends Control

@export_dir var actor_dir: String = "res://resources/actors/"
const PORTRAIT: PackedScene = preload("uid://dj5n66q8cooig")

# === Nodes ===
@onready var warriors: VBoxContainer = %Warriors
@onready var guardians: VBoxContainer = %Guardians
@onready var saboteurs: VBoxContainer = %Saboteurs
@onready var rearguards: VBoxContainer = %Rearguards
@onready var vanguard: VBoxContainer = %Vanguard

func _ready() -> void:
	EventBus.portrait_pressed.connect(_on_portrait_pressed)
	
	populate_grid()

func populate_grid() -> void:
	var dir := DirAccess.open(actor_dir)
	if not dir:
		push_error("[I AM ERROR] Failed to open actor directory: " + actor_dir)
		return
	
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var full_path := actor_dir + "/" + file_name
			var actor_data := is_ActorData(load(full_path))
			var grid: GridContainer
			var portrait: Portrait
			if actor_data:
				match actor_data.role:
					ActorData.Role.WARRIOR: 
						grid = warriors.get_node("GridContainer")
						portrait = create_portrait(actor_data)
					ActorData.Role.GUARDIAN:
						grid = guardians.get_node("GridContainer")
						portrait = create_portrait(actor_data)
					ActorData.Role.SABOTEUR: 
						grid = saboteurs.get_node("GridContainer")
						portrait = create_portrait(actor_data)
					ActorData.Role.REARGUARD:
						grid = rearguards.get_node("GridContainer")
						portrait = create_portrait(actor_data)
					_: return push_error("[I AM ERROR] Role not populated or found!")
				grid.add_child(portrait)
		file_name = dir.get_next()
	dir.list_dir_end()

func is_ActorData(res: Resource) -> ActorData:
	if res is ActorData:
		return res
	return null

func create_portrait(data: ActorData) -> Portrait:
	var portrait := PORTRAIT.instantiate()
	portrait.actor = data
	portrait.texture = portrait.actor.faceset
	portrait.name = portrait.actor.name
	return portrait

func _on_portrait_pressed(portrait: Portrait) -> void:
	vanguard.get_node("Actor/name").text = portrait.name
	vanguard.get_node("Actor/HBoxContainer/Portrait").add_child(portrait.duplicate())
	vanguard.get_node("Actor/HBoxContainer/Stats/type").text = "Type: " + DamageManager.Type.keys()[portrait.actor.type]
	vanguard.get_node("Actor/HBoxContainer/Stats/hp").text = "HP: " + str(portrait.actor.max_hp)
	vanguard.get_node("Actor/HBoxContainer/Stats/pwr").text = "PWR: " + str(portrait.actor.pwr)
	vanguard.get_node("Actor/HBoxContainer/Stats/dex").text = "DEX: " + str(portrait.actor.dex)
	vanguard.get_node("Actor/HBoxContainer/Stats/spd").text = "SPD: " + str(portrait.actor.spd)
	vanguard.get_node("Actor/HBoxContainer/Stats/rng").text = "RNG: " + str(portrait.actor.rng)
