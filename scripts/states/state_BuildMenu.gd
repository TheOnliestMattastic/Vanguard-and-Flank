extends Control

@export_dir var actor_dir: String = "res://resources/actors/"
const PORTRAIT: PackedScene = preload("uid://dj5n66q8cooig")

# === Nodes ===
@onready var warriors: VBoxContainer = %Warriors
@onready var guardians: VBoxContainer = %Guardians
@onready var saboteurs: VBoxContainer = %Saboteurs
@onready var rearguards: VBoxContainer = %Rearguards

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
			if actor_data:
				match actor_data.role:
					ActorData.Role.WARRIOR: 
						var grid := warriors.get_node("GridContainer")
						create_portrait(actor_data, grid)
					ActorData.Role.GUARDIAN:
						var grid := guardians.get_node("GridContainer")
						create_portrait(actor_data, grid)
					ActorData.Role.SABOTEUR: 
						var grid := saboteurs.get_node("GridContainer")
						create_portrait(actor_data, grid)
					ActorData.Role.REARGUARD:
						var grid := rearguards.get_node("GridContainer")
						create_portrait(actor_data, grid)
					_: push_error("[I AM ERROR] Role not populated or found!")
		file_name = dir.get_next()
	dir.list_dir_end()

func is_ActorData(res: Resource) -> ActorData:
	if res is ActorData:
		return res
	return null

func create_portrait(data: ActorData, role: GridContainer) -> void:
	var portrait := PORTRAIT.instantiate()
	portrait.texture = data.faceset
	role.add_child(portrait)

func _on_portrait_pressed(portrait_name: String) -> void:
	print(portrait_name)
