class_name IslandNode
extends Resource

enum IslandType { TOWN, FOREST, RUINS, VOLCANIC, FROZEN, DESERT, GRAND_LINE_GATE }

enum LocationType { PORT, TAVERN, MARKET, SHRINE, CAVE, BLACKSMITH, RUINS }

enum SecretLocationType {
	HIDDEN_LIBRARY,
	UNDERGROUND_MARKET,
	SECRET_DOCK,
	RADIO_TOWER,
	ABANDONED_LAB,
	FESTIVAL_GROUNDS,
}

class IslandLocation:
	var id:           String
	var label:        String
	var type:         LocationType
	var secret_type:  int = -1
	var map_position: Vector2
	var is_visited:   bool = false
	var is_secret:    bool = false

	func _init(p_id: String = "", p_label: String = "", p_type: LocationType = LocationType.PORT, p_pos: Vector2 = Vector2.ZERO) -> void:
		id           = p_id
		label        = p_label
		type         = p_type
		map_position = p_pos

@export var id: String = ""
@export var label: String = ""
@export var type: IslandType = IslandType.TOWN
@export var map_position: Vector2 = Vector2.ZERO
@export var connections: Array = []
@export var is_visited: bool = false

var locations: Array = []  # populated on first visit
var secret_locations: Array = [] 

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

func generate_secret_locations(secrets: Array) -> void:
	# secrets is a flat list of SecretLocationType values present in the crew
	# only generate each secret once even if multiple crew have it
	var w = 996.0
	var h = 240.0

	for secret in secrets:
		# skip if already generated
		var already = false
		for s in secret_locations:
			if s.secret_type == secret:
				already = true
				break
		if already:
			continue

		var loc = IslandLocation.new()
		loc.is_secret = true

		match secret:
			SecretLocationType.HIDDEN_LIBRARY:
				loc.id           = "hidden_library"
				loc.label        = "Hidden Library"
				loc.type         = LocationType.SHRINE   # reuse closest visual type
				loc.secret_type  = secret
				loc.map_position = Vector2(randf_range(w * 0.4, w * 0.7), randf_range(h * 0.1, h * 0.4))
			SecretLocationType.UNDERGROUND_MARKET:
				loc.id           = "underground_market"
				loc.label        = "Underground Market"
				loc.type         = LocationType.MARKET
				loc.secret_type  = secret
				loc.map_position = Vector2(randf_range(w * 0.4, w * 0.7), randf_range(h * 0.6, h * 0.9))
			SecretLocationType.SECRET_DOCK:
				loc.id           = "secret_dock"
				loc.label        = "Secret Dock"
				loc.type         = LocationType.PORT
				loc.secret_type  = secret
				loc.map_position = Vector2(randf_range(w * 0.6, w * 0.85), randf_range(h * 0.1, h * 0.5))
			SecretLocationType.RADIO_TOWER:
				loc.id           = "radio_tower"
				loc.label        = "Radio Tower"
				loc.type         = LocationType.SHRINE
				loc.secret_type  = secret
				loc.map_position = Vector2(randf_range(w * 0.5, w * 0.8), randf_range(h * 0.1, h * 0.4))
			SecretLocationType.ABANDONED_LAB:
				loc.id           = "abandoned_lab"
				loc.label        = "Abandoned Lab"
				loc.type         = LocationType.RUINS
				loc.secret_type  = secret
				loc.map_position = Vector2(randf_range(w * 0.5, w * 0.8), randf_range(h * 0.5, h * 0.9))
			SecretLocationType.FESTIVAL_GROUNDS:
				loc.id           = "festival_grounds"
				loc.label        = "Festival Grounds"
				loc.type         = LocationType.TAVERN
				loc.secret_type  = secret
				loc.map_position = Vector2(randf_range(w * 0.3, w * 0.6), randf_range(h * 0.4, h * 0.8))

		secret_locations.append(loc)

func get_location(loc_id: String) -> IslandLocation:
	for loc in locations:
		if loc.id == loc_id:
			return loc
	return null
