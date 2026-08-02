extends Control

@export_dir var actor_dir: String = "res://resources/actors/"
const PORTRAIT: PackedScene = preload("uid://dj5n66q8cooig")

# === Nodes ===
@onready var warriors: VBoxContainer = %Warriors
@onready var guardians: VBoxContainer = %Guardians
@onready var saboteurs: VBoxContainer = %Saboteurs
@onready var rearguards: VBoxContainer = %Rearguards
@onready var vanguard: VBoxContainer = %Vanguard
@onready var vanguard_units: HBoxContainer = %Vanguard_Units

func _ready() -> void:
	EventBus.portrait_pressed.connect(_on_portrait_pressed)
	EventBus.button_pressed.connect(_on_button_pressed)
	_populate_grid()

func _populate_grid() -> void:
	var dir := DirAccess.open(actor_dir)
	if not dir:
		push_error("[I AM ERROR] Failed to open actor directory: " + actor_dir)
		return
	
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var full_path := actor_dir + "/" + file_name
			var actor_data := _is_ActorData(load(full_path))
			var grid: GridContainer
			var portrait: Portrait
			if actor_data:
				match actor_data.role:
					ActorData.Role.WARRIOR: 
						grid = warriors.get_node("GridContainer")
						portrait = _create_portrait(actor_data)
					ActorData.Role.GUARDIAN:
						grid = guardians.get_node("GridContainer")
						portrait = _create_portrait(actor_data)
					ActorData.Role.SABOTEUR: 
						grid = saboteurs.get_node("GridContainer")
						portrait = _create_portrait(actor_data)
					ActorData.Role.REARGUARD:
						grid = rearguards.get_node("GridContainer")
						portrait = _create_portrait(actor_data)
					_: return push_error("[I AM ERROR] Role not populated or found!")
				grid.add_child(portrait)
		file_name = dir.get_next()
	dir.list_dir_end()

func _is_ActorData(res: Resource) -> ActorData:
	if res is ActorData:
		return res
	return null

func _create_portrait(data: ActorData) -> Portrait:
	var portrait := PORTRAIT.instantiate()
	portrait.actor = data
	portrait.texture = portrait.actor.faceset
	return portrait

var vanguard_select: Portrait
func _on_portrait_pressed(portrait: Portrait) -> void:
	# exit if player selects active portrait
	if portrait.get_parent() == vanguard.get_node("Actor/HBoxContainer/Portrait"):
		return
	
	# exit if player selects roster portrait
	if portrait.get_parent().get_parent() == vanguard_units:
		return
	
	# exit if combatant already selected
	if portrait.disabled:
		return
	
	# clear active portrait display
	for child in vanguard.get_node("Actor/HBoxContainer/Portrait").get_children():
		child.queue_free()
		
	vanguard_select = portrait
	vanguard.get_node("Actor/HBoxContainer/Portrait").add_child(portrait.duplicate())
	vanguard.get_node("Actor/name").text = vanguard_select.actor.name
	vanguard.get_node("Actor/HBoxContainer/Stats/type").text = "Type: " + DamageManager.Type.keys()[vanguard_select.actor.type]
	vanguard.get_node("Actor/HBoxContainer/Stats/hp").text = "HP: " + str(vanguard_select.actor.max_hp)
	vanguard.get_node("Actor/HBoxContainer/Stats/pwr").text = "PWR: " + str(vanguard_select.actor.pwr)
	vanguard.get_node("Actor/HBoxContainer/Stats/dex").text = "DEX: " + str(vanguard_select.actor.dex)
	vanguard.get_node("Actor/HBoxContainer/Stats/spd").text = "SPD: " + str(vanguard_select.actor.spd)
	vanguard.get_node("Actor/HBoxContainer/Stats/rng").text = "RNG: " + str(vanguard_select.actor.rng)

func _on_button_pressed(button) -> void:
	match button:
		"Vanguard_Confirm":
			if vanguard_select && not vanguard_select.disabled:
				Manifest.append_roster(vanguard_select, Manifest.Alignment.VANGUARD)
				_refresh_roster_display(Manifest.Alignment.VANGUARD)
		
		"Vanguard_Back":
			Manifest.pop_roster(Manifest.Alignment.VANGUARD)
			_refresh_roster_display(Manifest.Alignment.VANGUARD)
		
		_: print(button)

func _refresh_roster_display(aligment: Manifest.Alignment) -> void:
	var roster: Node
	var manifest: Array
	match aligment:
		Manifest.Alignment.VANGUARD:
			roster = vanguard_units
			manifest = Manifest.roster_vanguard
	
	# clear roster display
	for child in roster.get_children():
		if child.get_child_count() > 0:
			for grandchild in child.get_children():
				grandchild.queue_free()
	
	var unit = 0
	for child in manifest:
		var portrait = _create_portrait(child.actor)
		roster.get_child(unit).add_child(portrait)
		unit += 1
