class_name SailingEvent
extends Resource

enum Category { CREW_MOMENT, WEATHER, ENCOUNTER, DISCOVERY, GRAND_LINE }

enum Effect {
	NONE,
	STAT_BUFF,      # temporary boost to a crew stat
	STAT_DEBUFF,    # temporary penalty
	GAIN_RESOURCE,
	LOSE_RESOURCE,
}

class EventChoice:
	var label:   String
	var outcome: String   # flavor text shown after choice
	var effect:  Effect   = Effect.NONE
	var effect_value: int = 0

	func _init(p_label: String, p_outcome: String, p_effect: Effect = Effect.NONE, p_value: int = 0) -> void:
		label         = p_label
		outcome       = p_outcome
		effect        = p_effect
		effect_value  = p_value

var id:          String
var category:    Category
var title:       String
var description: String
var choices:     Array       # Array[EventChoice]
var requires:    Array       # Array[Character.Archetype] — empty means no requirement
