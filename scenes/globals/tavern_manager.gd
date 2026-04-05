extends Node
#
#signal tavern_entered(candidates: Array)   # Array[Character]
#signal recruit_condition_met(character: Character)
#signal recruit_joined(character: Character)
#signal tavern_empty
#
#var _current_candidates: Array = []   # characters available this visit
#
#func enter_tavern() -> void:
	#_current_candidates = _roll_candidates()
#
	#if _current_candidates.is_empty():
		#tavern_empty.emit()
	#else:
		#tavern_entered.emit(_current_candidates)
#
#func get_candidates() -> Array:
	#return _current_candidates
#
#func attempt_recruit(character: Character) -> void:
	#if character.join_condition == null:
		#_finalise_recruit(character)
		#return
#
	#match character.join_condition.type:
		#Character.JoinType.IMMEDIATE:
			#_finalise_recruit(character)
#
		#Character.JoinType.GOLD:
			## For now just resolve it — hook into ResourceManager later
			#print("Gold paid — hook into ResourceManager")
			#_finalise_recruit(character)
#
		#Character.JoinType.PROVE_STRENGTH:
			## Hook into combat system later
			## For now resolve immediately as placeholder
			#print("Combat triggered — hook into combat system")
			#_finalise_recruit(character)
#
		#Character.JoinType.FAVOUR:
			## Mark condition as pending — resolved when player
			## completes the relevant location visit
			#character.join_condition.resolved = false
			#print("Favour pending: ", character.join_condition.description)
			## They leave the tavern and wait at the dock
			#_current_candidates.erase(character)
#
		#Character.JoinType.SHARE_DREAM:
			## Wit check — hook into proper stat check later
			#var player = CrewManager.get_player()
			#var success = player.stats.wit >= 4 or randf() > 0.4
			#if success:
				#_finalise_recruit(character)
			#else:
				#print("Failed to convince them — try again later")
#
#func resolve_favour(character: Character) -> void:
	## Called when player completes the favour location
	#if character.join_condition == null:
		#return
	#if character.join_condition.type != Character.JoinType.FAVOUR:
		#return
	#character.join_condition.resolved = true
	#recruit_condition_met.emit(character)
	## They join when leaving the island
	#_queue_join_on_departure(character)
#
#func _queue_join_on_departure(character: Character) -> void:
	## Listen for the player leaving via the port
	#MapData.player_left_island.connect(
		#func(): _finalise_recruit(character),
		#CONNECT_ONE_SHOT
	#)
#
#func _finalise_recruit(character: Character) -> void:
	#character.is_recruit = false
	#character.join_condition = null
	#CrewManager.add_member(character)
	#_current_candidates.erase(character)
	#recruit_joined.emit(character)
#
#func _roll_candidates() -> Array:
	## 30% empty, 50% one candidate, 20% two candidates
	#var r = randf()
	#var count = 0
	#if r < 0.3:   count = 0
	#elif r < 0.8: count = 1
	#else:          count = 2
#
	#var result = []
	#for i in range(count):
		#result.append(CharacterGenerator.generate_random_crew_candidate())
	#return result
