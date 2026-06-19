extends AbilityData
class_name DamageSpike

func stage(caster: Actor) -> void:
	Grid.highlight_range(caster, cast_range, "red", true)

func execute(caster: Actor, coords: Vector2i) -> Dictionary:
	var target: Actor = Manifest.gridmap[coords].occupant
	var results: Dictionary = CombatManager.roll_for_attack(caster, target)
	if not results["success"]: return results # exit if attack was evaded
	Event.actor_damaged.emit(target, int(pwr_mod))
	return results
