extends Node

signal crew_changed

const MAX_CREW = 10

var members: Array = []  # Array[Character]

func _ready() -> void:
	_spawn_player()
	#_spawn_test_crew()

func _spawn_player() -> void:
	var p = Character.new()
	p.id         = _uid()
	p.name       = "Donkey D. Buffy"
	p.bounty     = 1500
	p.role       = Character.Role.CAPTAIN
	p.skill      = Character.Skill.NONE
	p.is_player  = true
	p.available_roles = []  # captain cannot change roles
	members.append(p)
	crew_changed.emit()

func _spawn_test_crew() -> void:
	var all_non_captain_roles = []
	for i in range(Character.Role.CREWMATE + 1):
		if i != Character.Role.CAPTAIN:
			all_non_captain_roles.append(i)
			
	var roles = [
		Character.Role.FIRST_MATE,
		Character.Role.NAVIGATOR,
		Character.Role.COOK,
		Character.Role.MEDIC,
		Character.Role.GUNNER,
		Character.Role.CARPENTER,
		Character.Role.SCHOLAR,
		Character.Role.QUARTERMASTER,
		Character.Role.CREWMATE,
	]
	var skills = Character.Skill.values()
	
	for role in roles:
		var c    = Character.new()
		c.id     = _uid()
		c.name   = NameGenerator.generate()
		c.bounty = randi_range(1000, 5000)
		c.role   = role
		c.skill  = skills.pick_random()
		c.available_roles = all_non_captain_roles.duplicate()
		members.append(c)
		
	crew_changed.emit()

func add_member(c: Character) -> bool:
	if members.size() >= MAX_CREW:
		return false
	if not c.id or c.id == "":
		c.id = _uid()
	members.append(c)
	crew_changed.emit()
	return true

func remove_member(id: String) -> void:
	for i in range(members.size()):
		if members[i].id == id:
			if members[i].is_player:
				return  # never remove the captain
			members.remove_at(i)
			crew_changed.emit()
			return

func assign_role(member_id: String, new_role: Character.Role) -> void:
	var target = get_member(member_id)
	if target == null:
		return

	# CREWMATE is unlimited — no conflict possible
	if new_role == Character.Role.CREWMATE:
		target.role = new_role
		crew_changed.emit()
		return

	# Check if another member holds this role already
	var holder = get_member_with_role(new_role)
	if holder != null and holder.id != member_id:
		# Swap — holder gets target's old role
		var old_role = target.role
		holder.role  = old_role
		target.role  = new_role
	else:
		target.role = new_role

	crew_changed.emit()

func get_member(id: String) -> Character:
	for m in members:
		if m.id == id:
			return m
	return null

func get_member_with_role(role: Character.Role) -> Character:
	for m in members:
		if m.role == role:
			return m
	return null

func get_player() -> Character:
	for m in members:
		if m.is_player:
			return m
	return null

func total_bounty() -> int:
	var total = 0
	for m in members:
		total += m.bounty
	return total

static func format_bounty(value: int) -> String:
	var s      = str(value)
	var result = ""
	var count  = 0
	for i in range(s.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = s[i] + result
		count += 1
	return result + " B"

func _uid() -> String:
	return str(randi()) + str(randi())



#extends Node
#
#signal crew_changed
#signal member_lost(character: Character, reason: String)
#
#enum LeaveReason { DISMISSED, DESERTED, DIED }
#
#var members: Array = []
#
#func _ready() -> void:
	#var player = CharacterGenerator.generate_player()
	#members.append(player)
#
#func add_member(c: Character) -> void:
	#members.append(c)
	## Regenerate secrets for current island immediately
	#_inject_secrets_into(MapData.get_current())
	#crew_changed.emit()
#
#func get_player() -> Character:
	#for m in members:
		#if m.is_player:
			#return m
	#return null
#
#func has_unlock(location_type: IslandNode.LocationType) -> bool:
	#for m in members:
		#if location_type in m.unlocks:
			#return true
	#return false
#
#func get_all_secrets() -> Array:
	## Flat deduplicated list of all SecretLocationType values in the crew
	#var result = []
	#for m in members:
		#for s in m.secrets:
			#if s not in result:
				#result.append(s)
	#return result
#
#func _inject_secrets_into(island: IslandNode) -> void:
	#island.generate_secret_locations(get_all_secrets())
#
#func inject_secrets_into_current() -> void:
	#_inject_secrets_into(MapData.get_current())
#
#func remove_member(c: Character, reason: LeaveReason) -> void:
	#if c.is_player:
		## Captain dying is game over — handle that separately
		#_handle_game_over()
		#return
#
	#members.erase(c)
#
	#match reason:
		#LeaveReason.DISMISSED: member_lost.emit(c, "was dismissed from the crew")
		#LeaveReason.DESERTED:  member_lost.emit(c, "has left the crew")
		#LeaveReason.DIED:
			#c.is_alive = false
			#member_lost.emit(c, "has died")
#
	## Rebuild secrets for current island since crew composition changed
	#inject_secrets_into_current()
	#crew_changed.emit()
#
#func remove_member_by_id(id: String, reason: LeaveReason) -> void:
	#for m in members:
		#if m.id == id:
			#remove_member(m, reason)
			#return
#
#func _handle_game_over() -> void:
	#print("Game over — the Captain has fallen")
