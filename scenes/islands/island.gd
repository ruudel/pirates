class_name Island
extends Resource

enum Terrain {
	TOWN, FOREST, MARSH, DESERT, FROZEN, RUINS, VOLCANIC
}

enum Sea {
	NORTH, SOUTH, EAST, WEST, GRAND_LINE
}

# Terrain pools per sea — grand line gets everything
const SEA_TERRAINS = {
	Sea.NORTH:      [Terrain.TOWN, Terrain.FOREST, Terrain.FROZEN],
	Sea.SOUTH:      [Terrain.TOWN, Terrain.MARSH,  Terrain.VOLCANIC],
	Sea.EAST:       [Terrain.TOWN, Terrain.DESERT, Terrain.RUINS],
	Sea.WEST:       [Terrain.TOWN, Terrain.FOREST, Terrain.MARSH],
	Sea.GRAND_LINE: [Terrain.TOWN, Terrain.FOREST, Terrain.MARSH,
					 Terrain.DESERT, Terrain.FROZEN, Terrain.RUINS, Terrain.VOLCANIC],
}

const NAME_PREFIXES = [
	"Iron", "Storm", "Black", "Red", "White", "Golden", "Silver",
	"Lost", "Broken", "Ancient", "Hollow", "Crimson", "Pale", "Dead",
	"Twin", "Lone", "Sunken", "Drifting", "Cursed", "Ashen"
]

const NAME_SUFFIXES = [
	"Rock", "Shore", "Isle", "Peak", "Cove", "Reef", "Bay",
	"Head", "Point", "Haven", "Hollow", "Moor", "Ridge", "Crag",
	"Spit", "Bank", "Reach", "Strand", "Keep", "Gate"
]

var id:          String
var name:        String
var terrain:     Terrain
var sea:         Sea
var map_position: Vector2

# Graph connections
var connections_out: Array = []  # Array[String] ids — max 2
var connections_in:  Array = []  # Array[String] ids — max 2

var is_visited:  bool = false
var is_current:  bool = false

static func generate_name() -> String:
	return NAME_PREFIXES.pick_random() + " " + NAME_SUFFIXES.pick_random()

static func terrain_name(t: Terrain) -> String:
	match t:
		Terrain.TOWN:     return "Town"
		Terrain.FOREST:   return "Forest"
		Terrain.MARSH:    return "Marsh"
		Terrain.DESERT:   return "Desert"
		Terrain.FROZEN:   return "Frozen"
		Terrain.RUINS:    return "Ruins"
		Terrain.VOLCANIC: return "Volcanic"
	return "Unknown"

static func sea_name(s: Sea) -> String:
	match s:
		Sea.NORTH:      return "North Blue"
		Sea.SOUTH:      return "South Blue"
		Sea.EAST:       return "East Blue"
		Sea.WEST:       return "West Blue"
		Sea.GRAND_LINE: return "Grand Line"
	return "Unknown"
