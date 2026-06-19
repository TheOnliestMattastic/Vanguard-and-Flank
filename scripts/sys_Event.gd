extends Node

# HUD
signal cell_pressed(coords: Vector2i)
signal button_pressed(name: String)

# Combat
signal actor_damaged(actor: Actor, ammount: int)
signal actor_defeated(actor: Actor)
signal game_over(loser: String)
