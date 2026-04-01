extends Node

signal crew_changed
signal member_lost(character: Character, reason: String)

enum LeaveReason { DISMISSED, DESERTED, DIED }

var members: Array = []

func _ready() -> void:
	var player = CharacterGenerator.generate_player()
	members.append(player)

func add_member(c: Character) -> void:
	members.append(c)
	# Regenerate secrets for current island immediately
	_inject_secrets_into(MapData.get_current())
	crew_changed.emit()

func get_player() -> Character:
	for m in members:
		if m.is_player:
			return m
	return null

func has_unlock(location_type: IslandNode.LocationType) -> bool:
	for m in members:
		if location_type in m.unlocks:
			return true
	return false

func get_all_secrets() -> Array:
	# Flat deduplicated list of all SecretLocationType values in the crew
	var result = []
	for m in members:
		for s in m.secrets:
			if s not in result:
				result.append(s)
	return result

func _inject_secrets_into(island: IslandNode) -> void:
	island.generate_secret_locations(get_all_secrets())

func inject_secrets_into_current() -> void:
	_inject_secrets_into(MapData.get_current())

func remove_member(c: Character, reason: LeaveReason) -> void:
	if c.is_player:
		# Captain dying is game over — handle that separately
		_handle_game_over()
		return

	members.erase(c)

	match reason:
		LeaveReason.DISMISSED: member_lost.emit(c, "was dismissed from the crew")
		LeaveReason.DESERTED:  member_lost.emit(c, "has left the crew")
		LeaveReason.DIED:
			c.is_alive = false
			member_lost.emit(c, "has died")

	# Rebuild secrets for current island since crew composition changed
	inject_secrets_into_current()
	crew_changed.emit()

func remove_member_by_id(id: String, reason: LeaveReason) -> void:
	for m in members:
		if m.id == id:
			remove_member(m, reason)
			return

func _handle_game_over() -> void:
	print("Game over — the Captain has fallen")
