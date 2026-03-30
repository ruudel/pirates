extends Control

enum MapMode { SEA, ISLAND }

const ICON_SIZE   = 18.0
const MAP_WIDTH   = 996.0
const MAP_HEIGHT  = 240.0
const ANCHOR_X    = MAP_WIDTH / 3.0
const PLAYER_COL  = Color("f7c948")
const VISITED_COL = Color("a8d8a8")
const UNKNOWN_COL = Color("666666")
const LINE_COL    = Color(0, 0, 0, 0.4)

var _buttons: Dictionary = {}
var _tween_offset: float = 0.0
var _player_marker: Label
var _current_mode: MapMode = MapMode.SEA

func _ready() -> void:
	_player_marker = $PlayerMarker
	MapData.player_moved.connect(_on_player_moved)
	MapData.travel_started.connect(_on_travel_started)
	_rebuild()

# ─── POSITION HELPERS ────────────────────────────────────────────────────────

func _get_sea_draw_position(island: IslandNode) -> Vector2:
	var current = MapData.get_current()
	var offset = Vector2(ANCHOR_X - current.map_position.x + _tween_offset, 0)
	return island.map_position + offset

# ─── MODE SWITCH ─────────────────────────────────────────────────────────────

func _zoom_out_to_sea() -> void:
	# Zoom out from the port location, not the island center
	var current = MapData.get_current()
	var port = current.get_location("port")
	var origin = port.map_position if port else Vector2(ANCHOR_X, current.map_position.y)
	pivot_offset = origin

	$NodeConnections.hide()  # already hidden in island mode but be explicit

	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", Vector2(3.0, 3.0), 0.6)
	tween.tween_callback(_swap_to_sea_mode)  # show() on connections happens inside here via _build_sea_map
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.6)

func _zoom_into_island() -> void:
	var current = MapData.get_current()
	pivot_offset = Vector2(ANCHOR_X, current.map_position.y)

	$NodeConnections.hide()  # hide lines before zoom starts

	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", Vector2(3.0, 3.0), 0.6)
	tween.tween_callback(_swap_to_island_mode)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.6)

func _swap_to_island_mode() -> void:
	_current_mode = MapMode.ISLAND
	_rebuild()

func _swap_to_sea_mode() -> void:
	_current_mode = MapMode.SEA
	_rebuild()

# ─── REBUILD ─────────────────────────────────────────────────────────────────

func _rebuild() -> void:
	for b in _buttons.values():
		b.queue_free()
	_buttons.clear()
	queue_redraw()

	if _current_mode == MapMode.ISLAND:
		_build_island_map()
	else:
		_build_sea_map()

func _build_sea_map() -> void:
	_tween_offset = 0.0
	var current    = MapData.get_current()
	var neighbours = MapData.get_neighbours()
	var visible_ids: Array = [current.id]
	for n in neighbours:
		visible_ids.append(n.id)

	for id in visible_ids:
		var node: IslandNode = MapData.islands[id]
		var draw_pos = _get_sea_draw_position(node)

		if draw_pos.x < -ICON_SIZE or draw_pos.x > MAP_WIDTH + ICON_SIZE:
			continue

		var btn = Button.new()
		btn.custom_minimum_size = Vector2(ICON_SIZE, ICON_SIZE)
		btn.position = draw_pos - Vector2(ICON_SIZE, ICON_SIZE) * 0.5
		btn.text = "★" if id == current.id else ("?" if not node.is_visited else _type_icon(node.type))
		btn.tooltip_text = node.label if node.is_visited else "Unknown island"
		btn.pressed.connect(_on_island_clicked.bind(id))
		add_child(btn)
		_buttons[id] = btn

	_place_marker_instant()
	_style_buttons()
	$NodeConnections.show()
	$NodeConnections.queue_redraw()

func _build_island_map() -> void:
	var current = MapData.get_current()
	$NodeConnections.hide()
	_player_marker.hide()

	for loc in current.locations:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(ICON_SIZE, ICON_SIZE)
		btn.position = loc.map_position - Vector2(ICON_SIZE, ICON_SIZE) * 0.5
		btn.text = _location_icon(loc.type)
		btn.tooltip_text = loc.label
		btn.pressed.connect(_on_location_clicked.bind(loc.id))
		add_child(btn)
		_buttons[loc.id] = btn

# ─── MARKER ──────────────────────────────────────────────────────────────────

func _place_marker_instant() -> void:
	_player_marker.show()
	var current  = MapData.get_current()
	var pos      = _get_sea_draw_position(current)
	_player_marker.position = pos - _player_marker.size * 0.5

func _reposition_buttons() -> void:
	if _current_mode == MapMode.ISLAND:
		return
	for id in _buttons:
		var node: IslandNode = MapData.islands[id]
		var draw_pos = _get_sea_draw_position(node)
		_buttons[id].position = draw_pos - Vector2(ICON_SIZE, ICON_SIZE) * 0.5
	var current = MapData.get_current()
	var marker_pos = _get_sea_draw_position(current)
	_player_marker.position = marker_pos - _player_marker.size * 0.5

# ─── STYLING ─────────────────────────────────────────────────────────────────

func _style_buttons() -> void:
	var current_id = MapData.current_island_id
	for id in _buttons:
		if not MapData.islands.has(id):
			continue
		var btn: Button  = _buttons[id]
		var node: IslandNode = MapData.islands[id]
		if id == current_id:
			btn.modulate = PLAYER_COL
		elif node.is_visited:
			btn.modulate = VISITED_COL
		else:
			btn.modulate = UNKNOWN_COL

# ─── SIGNALS ─────────────────────────────────────────────────────────────────

func _on_player_moved(_node: IslandNode) -> void:
	_zoom_into_island()

func _on_travel_started(from_node: IslandNode, to_node: IslandNode) -> void:
	var shift = from_node.map_position.x - to_node.map_position.x
	_tween_offset = 0.0

	var from_pos = _get_sea_draw_position(from_node) - _player_marker.size * 0.5
	var to_pos = Vector2(
		to_node.map_position.x + (ANCHOR_X - from_node.map_position.x + shift),
		to_node.map_position.y
	) - _player_marker.size * 0.5

	var tween = create_tween().set_parallel(true)
	tween.tween_method(_set_offset, 0.0, shift, 0.6)\
		 .set_ease(Tween.EASE_IN_OUT)\
		 .set_trans(Tween.TRANS_SINE)
	tween.tween_property(_player_marker, "position", to_pos, 0.6)\
		 .from(from_pos)\
		 .set_ease(Tween.EASE_IN_OUT)\
		 .set_trans(Tween.TRANS_SINE)

	tween.chain().tween_callback(MapData.finish_travel.bind(to_node.id))

func _on_island_clicked(id: String) -> void:
	if id == MapData.current_island_id or MapData.is_travelling:
		return
	MapData.travel_to(id)

func _on_location_clicked(loc_id: String) -> void:
	var current = MapData.get_current()
	var loc = current.get_location(loc_id)
	if loc == null:
		return
	if loc.type == IslandNode.LocationType.PORT:
		_zoom_out_to_sea()
	else:
		print("Entered: ", loc.label)  # replace with actual location logic later

func _set_offset(value: float) -> void:
	_tween_offset = value
	_reposition_buttons()
	$NodeConnections.queue_redraw()

# ─── ICONS ───────────────────────────────────────────────────────────────────

func _type_icon(type: IslandNode.IslandType) -> String:
	match type:
		IslandNode.IslandType.TOWN:     return "⌂"
		IslandNode.IslandType.FOREST:   return "♣"
		IslandNode.IslandType.RUINS:    return "▲"
		IslandNode.IslandType.VOLCANIC: return "🌋"
		IslandNode.IslandType.FROZEN:   return "❄"
		_:                              return "•"

func _location_icon(type: IslandNode.LocationType) -> String:
	match type:
		IslandNode.LocationType.PORT:        return "⚓"
		IslandNode.LocationType.TAVERN:      return "🍺"
		IslandNode.LocationType.MARKET:      return "🛒"
		IslandNode.LocationType.SHRINE:      return "⛩"
		IslandNode.LocationType.CAVE:        return "🕳"
		IslandNode.LocationType.BLACKSMITH:  return "⚒"
		_:                                   return "•"
