extends Node2D

func _ready() -> void:
	WorldMap.world_generated.connect(queue_redraw)
	WorldMap.current_island_changed.connect(func(_i): queue_redraw())

func _draw() -> void:
	if not WorldMap.islands:
		return

	var mini_map   = get_parent()
	var sea_islands = WorldMap.get_islands_in_sea(WorldMap.current_sea)

	for island in sea_islands:
		for to_id in island.connections_out:
			if not WorldMap.islands.has(to_id):
				continue
			var a = mini_map._draw_pos(island)
			var b = mini_map._draw_pos(WorldMap.islands[to_id])
			draw_line(a, b, Color(1, 1, 1, 0.3), 1.0)
