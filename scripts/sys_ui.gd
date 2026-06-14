extends Control
class_name UI

@onready var queue: VBoxContainer = %Queue
@onready var banner: Label = %BannerLabel
@onready var combat_log: RichTextLabel = %CombatLog
@onready var active_name: Label = %activeName
@onready var active_display: HBoxContainer = %activeDisplay
@onready var target_name: Label = %targetName
@onready var target_display: HBoxContainer = %targetDisplay
