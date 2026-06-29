extends Node

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()

func roll_die(sides: int) -> int:
	if sides <= 0:
		push_error("[I AM ERROR] Sides must be greater than 0.")
		return 0
	return rng.randi_range(1, sides)

func roll_many(count: int, sides: int) -> Array[int]:
	if count <= 0:
		push_error("[I AM ERROR] Count must be greater than 0.")
		return []
	if sides <= 0:
		push_error("[I AM ERROR] Sides must be greather than 0")
		return []
	var rolls: Array[int] = []
	for die in count:
		rolls.append(roll_die(sides))
	return rolls

func sum_rolls(rolls: Array[int]) -> int:
	var total: int = 0
	for value in rolls:
		total += value
	return total

func roll_dice(count: int, sides: int) -> int:
	return sum_rolls(roll_many(count, sides))

func roll_dice_plus(count: int, sides: int, modifier: int) -> int: 
	return roll_dice(count, sides) + modifier

func roll_report(count: int, sides: int) -> Dictionary:
	var rolls := roll_many(count, sides)
	return {
		"rolls": rolls,
		"total": sum_rolls(rolls)
	}

func roll_d4() -> int: return roll_die(4)
func roll_d6() -> int: return roll_die(6)
func roll_d8() -> int: return roll_die(8)
func roll_d10() -> int: return roll_die(10)
func roll_d20() -> int: return roll_die(20)
func roll_d100() -> int: return roll_die(100)
