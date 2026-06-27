extends Control
class_name UI

# === Scenes ===
@onready var portrait_scene = preload("uid://dj5n66q8cooig")
@onready var popup_scene = preload("uid://cec33augca57c")

# === Child Nodes ===
@onready var queue_display: VBoxContainer = %QueueDisplay
@onready var banner: Label = %BannerLabel
@onready var combat_log: RichTextLabel = %CombatLog
@onready var active_name: Label = %activeName
@onready var active_display: HBoxContainer = %activeDisplay
@onready var target_name: Label = %targetName
@onready var target_display: HBoxContainer = %targetDisplay

func _ready() -> void:
	Event.game_over.connect(_on_game_over)
	Event.actor_attacked.connect(log_hit_results)
	Event.actor_healed.connect(log_heal_results)
	Event.init_rolled.connect(log_init)
	Event.new_turn.connect(_on_new_turn)

# === HUD Functions ===
func display_queue(queue: Array[Actor]) -> void:
	var copy_of_queue = queue.duplicate() # use copy for function
	copy_of_queue.pop_front() # remove active actor
	copy_of_queue.reverse() # descending order for scrollbox
	for child in queue_display.get_children(): child.queue_free() # clear queue display
	for actor in copy_of_queue:
		var portrait = Manifest.combatants[actor]["portrait"].duplicate()
		queue_display.add_child(portrait)

func display_active(actor: Actor) -> void:
	for child in active_display.get_node("activePortrait").get_children(): child.queue_free()
	var portrait = Manifest.combatants[actor]["portrait"].duplicate()
	active_display.get_node("activePortrait").add_child(portrait)
	active_name.text = actor.data.name
	active_display.get_node("activeStats/hp").text = "HP: " + str(Manifest.combatants[actor]["HP"])
	active_display.get_node("activeStats/ap").text = "AP: " + str(Manifest.combatants[actor]["AP"])
	active_display.get_node("activeStats/pwr").text = "PWR: " + str(actor.data.pwr)
	active_display.get_node("activeStats/dex").text = "DEX: " + str(actor.data.dex)
	active_display.get_node("activeStats/spd").text = "SPD: " + str(actor.data.spd)

func display_target(actor: Actor) -> void:
	var portrait = Manifest.combatants[actor]["portrait"].duplicate()
	for child in target_display.get_node("targetPortrait").get_children(): child.queue_free()
	target_display.get_node("targetPortrait").add_child(portrait)
	target_name.text = actor.data.name
	target_display.get_node("targetStats/hp").text = "HP: " + str(Manifest.combatants[actor]["HP"])
	target_display.get_node("targetStats/ap").text = "AP: " + str(Manifest.combatants[actor]["AP"])
	target_display.get_node("targetStats/pwr").text = "PWR: " + str(actor.data.pwr)
	target_display.get_node("targetStats/dex").text = "DEX: " + str(actor.data.dex)
	target_display.get_node("targetStats/spd").text = "SPD: " + str(actor.data.spd)

func log_init() -> void:
	for combatant in Manifest.combatants:
		combat_log.append_text("[[color=yellow]INITIATIVE[/color]] " + combatant.name + " rolled a [color=cyan]" + str(Manifest.combatants[combatant]["init"]) + "[/color]![br]")

func log_to_banner(message: String) -> void:
	banner.text = message

func log_hit_results(attacker: Actor, roll: int, dc: int) -> void:
	combat_log.append_text("[[color=red]ATTACK[/color]] [color=blue]" + attacker.name + "[/color] must roll higher than DC: [color=cyan]" + str(dc) + "[/color] to succeed.[br]" )
	combat_log.append_text("[color=blue]" + attacker.name + "[/color] rolled a [color=cyan]" + str(roll) + "[/color]![br]")
	if dc > roll : combat_log.append_text("The [color=red]attack failed[/color].[br]")
	else: combat_log.append_text("The [color=green]attack succeeded[/color].[br]")

func log_heal_results(caster: Actor, target: Actor, ammount: int = 1) -> void:
	combat_log.append_text("[[color=green]HEAL[/color]] [color=blue]" + caster.name + "[/color] healed [color=blue]" + target.name + "[/color] for [color=cyan]" + str(ammount) + "[/color] pts![br]")

func append_log(message: String) -> void:
	combat_log.append_text(message)

func _on_game_over(loser: String) -> void:
	var winner
	if loser == "Vanguard": winner = "Flank"
	else: winner = "Vanguard"
	
	var popup = popup_scene.instantiate()
	popup.get_node("Panel/MarginContainer/VBoxContainer/Title").text = "Game Over"
	popup.get_node("Panel/MarginContainer/VBoxContainer/Body").text = winner + " won!"
	popup.get_node("Panel/MarginContainer/VBoxContainer/HBoxContainer/LeftButton").text = "Main Menu"
	popup.get_node("Panel/MarginContainer/VBoxContainer/HBoxContainer/RightButton").text = "Quit"	
	add_child(popup)

func _on_new_turn() -> void:
	display_queue(Manifest.queue)
