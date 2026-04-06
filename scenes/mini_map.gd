extends Control

@export var highlight_shader: ShaderMaterial
@export var terrain_textures: Array[Texture2D] = []

const ANCHOR_X   = 996.0 / 3.0
const MAP_WIDTH  = 996.0
const MAP_HEIGHT = 240.0
const NODE_SIZE  = 72
const LINE_COLOR = Color(0.0, 0.0, 0.0, 1.0)

const COLORS = {
	"current":   Color("f7c948"),
	"visited":   Color("a8d8a8"),
	"reachable": Color("ffffff"),
	"unknown":   Color("555555"),
}

var _island_nodes:   Dictionary = {}  # id -> TextureButton
var _player_marker:  Sprite2D
var _connections:    Node2D

func _ready() -> void:
	_connections   = $Connections
	_player_marker = $PlayerMarker
	WorldMap.world_generated.connect(_rebuild)
	WorldMap.current_island_changed.connect(_on_island_changed)
	_rebuild()

# ── build ─────────────────────────────────────────────────────────────────────

func _rebuild() -> void:
	for child in _island_nodes.values():
		child.queue_free()
	_island_nodes.clear()
	_connections.queue_redraw()

	var sea_islands = WorldMap.get_islands_in_sea(WorldMap.current_sea)
	for island in sea_islands:
		_spawn_node(island)
	_place_marker()

func _spawn_node(island: Island) -> void:
	var btn = TextureButton.new()
	btn.custom_minimum_size = Vector2(NODE_SIZE, NODE_SIZE)
	btn.ignore_texture_size = true
	btn.stretch_mode        = TextureButton.STRETCH_KEEP_ASPECT_CENTERED

	# Assign terrain texture
	var terrain_index = island.terrain as int
	if terrain_index < terrain_textures.size() and terrain_textures[terrain_index] != null:
		btn.texture_normal = terrain_textures[terrain_index]

	btn.position     = _draw_pos(island) - Vector2(NODE_SIZE, NODE_SIZE) * 0.5
	btn.tooltip_text = "%s\n%s" % [island.name, Island.terrain_name(island.terrain)]
	btn.mouse_entered.connect(_on_hover.bind(island.id, true))
	btn.mouse_exited.connect(_on_hover.bind(island.id, false))
	btn.pressed.connect(_on_clicked.bind(island.id))
	btn.modulate     = _color_for(island)
	add_child(btn)
	_island_nodes[island.id] = btn

func _place_marker() -> void:
	if _player_marker == null:
		return
	var current = WorldMap.get_current()
	_player_marker.position = _draw_pos(current) - _player_marker.texture.get_size() * 0.5

# ── draw connections ──────────────────────────────────────────────────────────

 #In Connections (Node2D) script:
func _draw() -> void:
	print("drawing connections, island count: ", WorldMap.islands.size())
	for island in WorldMap.get_islands_in_sea(WorldMap.current_sea):
		for to_id in island.connections_out:
			if WorldMap.islands.has(to_id):
				var a = _draw_pos(island)
				var b = _draw_pos(WorldMap.islands[to_id])
				draw_line(a, b, Color(0.0, 0.0, 0.0, 1.0), 1.0)

# ── positioning ───────────────────────────────────────────────────────────────

func _draw_pos(island: Island) -> Vector2:
	# Offset so current island sits at ANCHOR_X
	var current = WorldMap.get_current()
	var offset  = Vector2(ANCHOR_X - current.map_position.x, 0)
	return island.map_position + offset

# ── interaction ───────────────────────────────────────────────────────────────

func _on_clicked(id: String) -> void:
	if id == WorldMap.current_id:
		return
	var island = WorldMap.islands[id]
	if id not in WorldMap.get_current().connections_out:
		return
	WorldMap.travel_to(id)

func _on_hover(id: String, hovering: bool) -> void:
	if not _island_nodes.has(id):
		return
	var btn    = _island_nodes[id]
	var island = WorldMap.islands[id]
	if hovering:
		btn.modulate = _color_for(island).lightened(0.3)
		# apply highlight shader here
	else:
		btn.modulate = _color_for(island)

func _on_island_changed(_island: Island) -> void:
	_rebuild()

# ── helpers ───────────────────────────────────────────────────────────────────

func _color_for(island: Island) -> Color:
	if island.is_current:
		return COLORS["current"]
	if island.id in WorldMap.get_current().connections_out:
		return COLORS["reachable"]
	if island.is_visited:
		return COLORS["visited"]
	return COLORS["unknown"]
