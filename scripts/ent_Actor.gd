@tool
extends Area2D
class_name Actor

@export var data: ActorData
@onready var sprite: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer
var active: bool = false
var target: bool = false

func _ready() -> void:
	if not data: return
	if data.spritesheet: sprite.set_texture(data.spritesheet)
	if data.name: self.name = data.name

func _process(delta: float) -> void:
	if target or active: anim.play("walk_down")
	else: anim.play("idle_down")

func _on_mouse_entered() -> void:
	target = true

func _on_mouse_exited() -> void:
	target = false
