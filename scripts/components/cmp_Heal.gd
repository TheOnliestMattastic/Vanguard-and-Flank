extends AbilityData
class_name Heal

func stage(caster: Actor) -> void:
	Grid.highlight_range(caster, cast_range, "green", true, true)

func execute(caster: Actor, coords: Vector2i) -> bool:
	EventBus.actor_healed.emit(caster, Manifest.gridmap[coords].occupant, int(pwr_mod))
	return true
