extends AbilityData
class_name Heal

func stage(caster: Actor) -> void:
	Grid.highlight_range(caster, cast_range, "green", true, true)

func execute(caster: Actor, coords: Vector2i) -> Dictionary:
	var results: Dictionary
	var target: Actor = Manifest.gridmap[coords].occupant
	var current_hp = Manifest.combatants[target]["HP"]
	var heal = min(roundi(current_hp + pwr_mod), target.data.max_hp)
	results["success"] = true
	results["caster"] = caster
	results["target"] = target
	results["ammount"] = heal - current_hp
	return results
