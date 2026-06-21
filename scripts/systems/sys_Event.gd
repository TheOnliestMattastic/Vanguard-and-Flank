extends Node

# Input
signal cell_pressed(coords: Vector2i)
signal button_pressed(name: String)

# Game
signal init_rolled()
signal new_turn() 
signal new_round()
signal game_over(loser: String)

# Combat
signal actor_attacked(attacker: Actor, defender: Actor, result: int, dc: int)
signal actor_damaged(actor: Actor, ammount: int)
signal actor_healed(caster: Actor, target: Actor, ammount: int)
signal actor_doted(actor: Actor, dot_name: String, turns: int)
signal actor_defeated(actor: Actor)
