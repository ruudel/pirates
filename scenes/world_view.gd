extends Control

var town_docked = preload("res://graphics/backgrounds/town_dock.png")
var forest_docked = preload("res://graphics/backgrounds/forest_dock.png")
var ruins_docked = preload("res://graphics/backgrounds/ruins_dock.png")
var volcano_docked = preload("res://graphics/backgrounds/volcano_dock.png")
var frozen_docked = preload("res://graphics/backgrounds/frozen_dock.png")
var desert_docked = preload("res://graphics/backgrounds/desert_dock.png")

func _ready() -> void:
	MapData.player_moved.connect(_on_player_moved)
	_on_player_moved(MapData.get_current())  # show initial scene

func _on_player_moved(node: IslandNode) -> void:
	match node.type:
		IslandNode.IslandType.TOWN:     $Sprite2D.texture = (town_docked)
		IslandNode.IslandType.FOREST:   $Sprite2D.texture = (forest_docked)
		IslandNode.IslandType.RUINS:    $Sprite2D.texture = (ruins_docked)
		IslandNode.IslandType.VOLCANIC: $Sprite2D.texture = (volcano_docked)
		IslandNode.IslandType.FROZEN: $Sprite2D.texture = (frozen_docked)
		IslandNode.IslandType.DESERT: $Sprite2D.texture = (desert_docked)
		_:                              pass
