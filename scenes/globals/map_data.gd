# map_data.gd
extends Node

signal player_moved(to_node: IslandNode)
signal travel_started(from_node: IslandNode, to_node: IslandNode)
signal player_left_island

var islands: Dictionary = {}
var current_island_id: String = ""
var is_travelling: bool = false

func _ready() -> void:
	_generate_starter_sea()

func get_current() -> IslandNode:
	return islands[current_island_id]

func get_neighbours() -> Array:
	var result: Array = []
	for id in get_current().connections:
		if islands.has(id):
			result.append(islands[id])
	return result

# Fire this in travel_to() before begin_sailing:
func travel_to(id: String, grand_line: bool = false) -> void:
	if is_travelling:
		return
	if id in get_current().connections:
		is_travelling = true
		player_left_island.emit()
		var destination = islands[id]
		travel_started.emit(get_current(), destination)

func begin_sailing(destination_id: String) -> void:
	SailingManager.start_sailing(destination_id)

func finish_travel(id: String) -> void:
	islands[current_island_id].is_visited = true
	current_island_id = id
	islands[current_island_id].generate_locations()
	CrewManager.inject_secrets_into_current()  # add this line
	is_travelling = false
	player_moved.emit(get_current())

func _generate_starter_sea() -> void:
	var map_width  = 996
	var padding    = 60
	var island_count = 7
	var column_width = (map_width - padding * 2) / (island_count - 1)

	# Each entry: [id, label, type, y_fraction, [connection indices]]
	# y_fraction: 0.0 = top, 1.0 = bottom of safe band
	var data = [
		["start",    "Windmill Village", IslandNode.IslandType.TOWN,     0.5,  [1, 2]],
		["island_a", "???",              IslandNode.IslandType.FOREST,   0.2,  [0, 3]],
		["island_b", "???",              IslandNode.IslandType.RUINS,    0.8,  [0, 4]],
		["island_c", "???",              IslandNode.IslandType.TOWN,     0.15, [1, 5]],
		["island_d", "???",              IslandNode.IslandType.VOLCANIC, 0.85, [2, 5]],
		["island_e", "???",              IslandNode.IslandType.FROZEN,   0.5,  [3, 4, 6]],
		["island_f", "???",              IslandNode.IslandType.TOWN,     0.5,  [5]],
	]

	var y_min = 40.0
	var y_max = 200.0

	for i in range(data.size()):
		var d = data[i]
		var node = IslandNode.new()
		node.id    = d[0]
		node.label = d[1]
		node.type  = d[2]
		node.map_position = Vector2(
			padding + i * column_width,
			lerp(y_min, y_max, d[3])
		)
		# Build connections from index list
		node.connections = []
		for j in d[4]:
			node.connections.append(data[j][0])
		islands[node.id] = node

	current_island_id = "start"
	islands[current_island_id].is_visited = true
