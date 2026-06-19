extends AbilityData
class_name DamageSpike

func stage(caster: Actor) -> void:
	Grid.highlight_range(caster, cast_range, "red", true)

func execute(caster: Actor, coords: Vector2i) -> bool:
	var target: Actor = Manifest.gridmap[coords].occupant
	if CombatManager.roll_for_attack(caster, target): 
		Event.actor_damaged.emit(target, int(pwr_mod))
	return true
