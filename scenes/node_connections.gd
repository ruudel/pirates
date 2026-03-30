# node_connections.gd
extends Node2D

func _ready() -> void:
	MapData.player_moved.connect(_on_player_moved)
	MapData.travel_started.connect(_on_travel_started)
	queue_redraw()

func _on_player_moved(_node) -> void:
	queue_redraw()

func _on_travel_started(_from, _to) -> void:
	queue_redraw()

func _draw() -> void:
	var mini_map = get_parent()  # assumes ConnectionsLayer is direct child of MiniMap
	var current  = MapData.get_current()
	var offset   = Vector2(mini_map.ANCHOR_X - current.map_position.x + mini_map._tween_offset, 0)

	for neighbour in MapData.get_neighbours():
		var a = current.map_position   + offset
		var b = neighbour.map_position + offset
		draw_line(a, b, Color(0, 0, 0, 0.6), 1.5)
