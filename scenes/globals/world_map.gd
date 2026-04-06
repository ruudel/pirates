extends Node

signal world_generated
signal current_island_changed(island: Island)

const ISLANDS_PER_SEA_MIN = 6
const ISLANDS_PER_SEA_MAX = 12

# Minimap bounds — islands are placed within this space
const MAP_WIDTH  = 996.0
const MAP_HEIGHT = 240.0
const PADDING    = 60.0
const MIN_DIST   = 80.0   # minimum distance between any two islands

var islands:     Dictionary = {}   # id -> Island
var current_id:  String     = ""
var current_sea: Island.Sea

func _ready() -> void:
	generate()

func generate() -> void:
	islands.clear()
	current_sea = _random_starting_sea()

	for sea in [Island.Sea.NORTH, Island.Sea.SOUTH,
				Island.Sea.EAST,  Island.Sea.WEST, Island.Sea.GRAND_LINE]:
		_generate_sea(sea)

	# Set starting island
	var sea_islands = get_islands_in_sea(current_sea)
	sea_islands.shuffle()
	current_id = sea_islands[0].id
	islands[current_id].is_current = true
	islands[current_id].is_visited = true

	world_generated.emit()

func get_current() -> Island:
	return islands[current_id]

func get_islands_in_sea(sea: Island.Sea) -> Array:
	var result = []
	for island in islands.values():
		if island.sea == sea:
			result.append(island)
	return result

func get_neighbours() -> Array:
	var current = get_current()
	var result  = []
	for id in current.connections_out:
		if islands.has(id):
			result.append(islands[id])
	return result

func travel_to(id: String) -> void:
	if not islands.has(id):
		return
	if id not in get_current().connections_out:
		return

	islands[current_id].is_current = false
	current_id = id
	islands[current_id].is_current = true
	islands[current_id].is_visited = true
	current_island_changed.emit(islands[current_id])

# ── generation ────────────────────────────────────────────────────────────────

func _generate_sea(sea: Island.Sea) -> void:
	var count        = randi_range(ISLANDS_PER_SEA_MIN, ISLANDS_PER_SEA_MAX)
	var terrain_pool = Island.SEA_TERRAINS[sea]
	var placed       = []   # Array[Island] — used for connection logic

	for i in range(count):
		var island          = Island.new()
		island.id           = _uid()
		island.name         = Island.generate_name()
		island.terrain      = terrain_pool.pick_random()
		island.sea          = sea
		island.map_position = _find_free_position(placed)
		islands[island.id]  = island
		placed.append(island)

	# Sort left to right so connections flow forward
	placed.sort_custom(func(a, b): return a.map_position.x < b.map_position.x)

	# Build connections — guaranteed chain + optional branch
	for i in range(placed.size()):
		var island = placed[i]

		# Connect forward to next island (guaranteed)
		if i + 1 < placed.size():
			_connect(island, placed[i + 1])

		# 40% chance of an additional forward branch
		if i + 2 < placed.size() and randf() < 0.4:
			if island.connections_out.size() < 2:
				_connect(island, placed[i + 2])

func _connect(from: Island, to: Island) -> void:
	if from.connections_out.size() >= 2:
		return
	if to.connections_in.size() >= 2:
		return
	if to.id in from.connections_out:
		return
	from.connections_out.append(to.id)
	to.connections_in.append(from.id)

func _find_free_position(placed: Array) -> Vector2:
	var attempts = 0
	while attempts < 100:
		var pos = Vector2(
			randf_range(PADDING, MAP_WIDTH  - PADDING),
			randf_range(PADDING, MAP_HEIGHT - PADDING)
		)
		var too_close = false
		for other in placed:
			if pos.distance_to(other.map_position) < MIN_DIST:
				too_close = true
				break
		if not too_close:
			return pos
		attempts += 1
	# Fallback — place anywhere
	return Vector2(
		randf_range(PADDING, MAP_WIDTH  - PADDING),
		randf_range(PADDING, MAP_HEIGHT - PADDING)
	)

func _random_starting_sea() -> Island.Sea:
	var seas = [Island.Sea.NORTH, Island.Sea.SOUTH,
				Island.Sea.EAST,  Island.Sea.WEST]
	seas.shuffle()
	return seas[0]

func _uid() -> String:
	return str(randi()) + str(randi())
