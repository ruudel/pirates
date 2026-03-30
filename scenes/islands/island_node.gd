class_name IslandNode
extends Resource

enum IslandType { TOWN, FOREST, RUINS, VOLCANIC, FROZEN, DESERT, GRAND_LINE_GATE }

enum LocationType { PORT, TAVERN, MARKET, SHRINE, CAVE, BLACKSMITH }

class IslandLocation:
	var id: String
	var label: String
	var type: LocationType
	var map_position: Vector2
	var is_visited: bool = false

	func _init(p_id: String, p_label: String, p_type: LocationType, p_pos: Vector2) -> void:
		id = p_id
		label = p_label
		type = p_type
		map_position = p_pos

@export var id: String = ""
@export var label: String = ""
@export var type: IslandType = IslandType.TOWN
@export var map_position: Vector2 = Vector2.ZERO
@export var connections: Array = []
@export var is_visited: bool = false

var locations: Array = []  # populated on first visit

func generate_locations() -> void:
	if locations.size() > 0:
		return  # already generated, don't regenerate on revisit
	
	var w = 996.0
	var h = 240.0

	match type:
		IslandType.TOWN:
			locations = [
				IslandLocation.new("port",       "Port",       LocationType.PORT,       Vector2(w * 0.15, h * 0.5)),
				IslandLocation.new("tavern",      "Tavern",     LocationType.TAVERN,     Vector2(w * 0.45, h * 0.3)),
				IslandLocation.new("market",      "Market",     LocationType.MARKET,     Vector2(w * 0.75, h * 0.6)),
			]
		IslandType.FOREST:
			locations = [
				IslandLocation.new("port",        "Port",       LocationType.PORT,       Vector2(w * 0.15, h * 0.5)),
				IslandLocation.new("shrine",      "Shrine",     LocationType.SHRINE,     Vector2(w * 0.5,  h * 0.25)),
				IslandLocation.new("cave",        "Cave",       LocationType.CAVE,       Vector2(w * 0.8,  h * 0.7)),
			]
		IslandType.RUINS:
			locations = [
				IslandLocation.new("port",        "Port",       LocationType.PORT,       Vector2(w * 0.15, h * 0.5)),
				IslandLocation.new("ruins",       "Old Ruins",  LocationType.SHRINE,     Vector2(w * 0.55, h * 0.35)),
				IslandLocation.new("cave",        "Cave",       LocationType.CAVE,       Vector2(w * 0.8,  h * 0.65)),
			]
		IslandType.VOLCANIC:
			locations = [
				IslandLocation.new("port",        "Port",       LocationType.PORT,       Vector2(w * 0.15, h * 0.5)),
				IslandLocation.new("blacksmith",  "Forge",      LocationType.BLACKSMITH, Vector2(w * 0.5,  h * 0.4)),
				IslandLocation.new("cave",        "Lava Cave",  LocationType.CAVE,       Vector2(w * 0.8,  h * 0.6)),
			]
		IslandType.FROZEN:
			locations = [
				IslandLocation.new("port",        "Port",       LocationType.PORT,       Vector2(w * 0.15, h * 0.5)),
				IslandLocation.new("tavern",      "Tavern",     LocationType.TAVERN,     Vector2(w * 0.45, h * 0.3)),
				IslandLocation.new("cave",        "Ice Cave",   LocationType.CAVE,       Vector2(w * 0.8,  h * 0.65)),
			]
		_:
			locations = [
				IslandLocation.new("port",        "Port",       LocationType.PORT,       Vector2(w * 0.15, h * 0.5)),
			]

func get_location(loc_id: String) -> IslandLocation:
	for loc in locations:
		if loc.id == loc_id:
			return loc
	return null
