class_name Character
extends Resource

enum Role {
	CAPTAIN, FIRST_MATE, COOK, NAVIGATOR,
	CARPENTER, MEDIC, GUNNER, SCHOLAR,
	QUARTERMASTER, CREWMATE
}

# Skill pool — role agnostic, assign freely
enum Skill {
	NONE,
	ENDURANCE, TENACITY, INTELLIGENCE, PSYCHOLOGY, LORE, CHARISMA,
	LUCK, OCCULTISM, TECHNOLOGY, BARTERING, PERCEPTION, INTIMIDATION,
	DECEPTION
}

var id:      String
var name:    String
var bounty:  int = 0
var role:    Role = Role.CREWMATE
var skill:   Skill = Skill.NONE
var is_player: bool = false
var available_roles: Array = []

static func role_name(r: Role) -> String:
	match r:
		Role.CAPTAIN:       return "Captain"
		Role.FIRST_MATE:    return "First Mate"
		Role.COOK:          return "Cook"
		Role.NAVIGATOR:     return "Navigator"
		Role.CARPENTER:     return "Carpenter"
		Role.MEDIC:         return "Medic"
		Role.GUNNER:        return "Gunner"
		Role.SCHOLAR:       return "Scholar"
		Role.QUARTERMASTER: return "Quartermaster"
		Role.CREWMATE:      return "Crewmate"
	return "Unknown"

static func skill_name(s: Skill) -> String:
	match s:
		Skill.NONE:			return "—"
		Skill.ENDURANCE: 	return "Endurance"
		Skill.TENACITY:  	return "Tenacity"
		Skill.INTELLIGENCE:	return "Intelligence"
		Skill.PSYCHOLOGY:	return "Psychology"
		Skill.LORE:			return "Lore"
		Skill.CHARISMA:		return "Charisma"
		Skill.LUCK:			return "Luck"
		Skill.OCCULTISM:	return "Occultism"
		Skill.TECHNOLOGY:	return "Technology"
		Skill.BARTERING:	return "Bartering"
		Skill.PERCEPTION:	return "Perception"
		Skill.INTIMIDATION:	return "Intimidation"
		Skill.DECEPTION:	return "Deception"
	return "Unknown"


#class_name Character
#extends Resource
#
#enum Archetype {
	#CAPTAIN, FIGHTER, NAVIGATOR, COOK, DOCTOR, SCOUT,
	#SCHOLAR, SPY, SHIPWRIGHT, COMMUNICATOR, ENGINEER, MUSICIAN
#}
#
#enum Trait {
	## Positive
	#BRAVE, CALM, CUNNING, LOYAL, CHEERFUL, STOIC, KIND,
	## Neutral / double-edged
	#RECKLESS, GREEDY, SUSPICIOUS,
	## Negative
	#STUPID, COWARD, SHY, ARROGANT, GLUTTON, LAZY, DISHONEST
#}
#
#enum Ability {
	#INSPIRING_ROAR,   # Captain   — boosts all crew stats for one round
	#POWER_STRIKE,     # Fighter   — heavy single target damage
	#CHART_COURSE,     # Navigator — skip next sailing event once
	#RALLY,            # Cook      — restore resilience mid combat
	#PATCH_UP,         # Doctor    — remove injured status
	#AMBUSH,           # Scout     — crew acts first in next combat
	#ANALYZE,          # Scholar   — reveal enemy weaknesses
	#VANISH,           # Spy       — avoid one combat encounter entirely
	#REINFORCE,        # Shipwright— repair ship hull mid sailing event
	#BROADCAST,        # Communicator — call for aid, reduces enemy count
	#OVERCLOCK,        # Engineer  — supercharge one ally ability this fight
	#SHANTY,           # Musician  — raise crew morale, buff luck for encounter
#}
#
#class StatBlock:
	#var strength:   int = 1
	#var navigation: int = 1
	#var luck:       int = 1
	#var resilience: int = 1
	#var wit:        int = 1
#
	#func _init(s: int, nav: int, l: int, r: int, w: int) -> void:
		#strength   = s
		#navigation = nav
		#luck       = l
		#resilience = r
		#wit        = w
#
	#func total() -> int:
		#return strength + navigation + luck + resilience + wit
#
#var id:         String
#var name:       String
#var archetype:  Archetype
#var role:       String
#var stats:      StatBlock
#var traits:     Array
#var ability:    Ability
#var unlocks:    Array   # existing LocationTypes this character enables
#var secrets:    Array   # secret LocationTypes only this character can reveal
#var is_player:  bool = false
#var is_alive:   bool = true
#var join_condition: Character.JoinCondition = null   # null means already crew
#var is_recruit:     bool = false           # true if met in tavern, not yet recruited
#
#func archetype_name() -> String:
	#match archetype:
		#Archetype.CAPTAIN:       return "Captain"
		#Archetype.FIGHTER:       return "Fighter"
		#Archetype.NAVIGATOR:     return "Navigator"
		#Archetype.COOK:          return "Cook"
		#Archetype.DOCTOR:        return "Doctor"
		#Archetype.SCOUT:         return "Scout"
		#Archetype.SCHOLAR:       return "Scholar"
		#Archetype.SPY:           return "Spy"
		#Archetype.SHIPWRIGHT:    return "Shipwright"
		#Archetype.COMMUNICATOR:  return "Communicator"
		#Archetype.ENGINEER:      return "Engineer"
		#Archetype.MUSICIAN:      return "Musician"
		#_:                       return "Unknown"
#
#func trait_name(t: Trait) -> String:
	#match t:
		#Trait.BRAVE:      return "Brave"
		#Trait.CALM:       return "Calm"
		#Trait.CUNNING:    return "Cunning"
		#Trait.LOYAL:      return "Loyal"
		#Trait.CHEERFUL:   return "Cheerful"
		#Trait.STOIC:      return "Stoic"
		#Trait.KIND:       return "Kind"
		#Trait.RECKLESS:   return "Reckless"
		#Trait.GREEDY:     return "Greedy"
		#Trait.SUSPICIOUS: return "Suspicious"
		#Trait.STUPID:     return "Stupid"
		#Trait.COWARD:     return "Coward"
		#Trait.SHY:        return "Shy"
		#Trait.ARROGANT:   return "Arrogant"
		#Trait.GLUTTON:    return "Glutton"
		#Trait.LAZY:       return "Lazy"
		#Trait.DISHONEST:  return "Dishonest"
		#_:                return "Unknown"
#
#func ability_name() -> String:
	#match ability:
		#Ability.INSPIRING_ROAR: return "Inspiring Roar"
		#Ability.POWER_STRIKE:   return "Power Strike"
		#Ability.CHART_COURSE:   return "Chart Course"
		#Ability.RALLY:          return "Rally"
		#Ability.PATCH_UP:       return "Patch Up"
		#Ability.AMBUSH:         return "Ambush"
		#Ability.ANALYZE:        return "Analyze"
		#Ability.VANISH:         return "Vanish"
		#Ability.REINFORCE:      return "Reinforce"
		#Ability.BROADCAST:      return "Broadcast"
		#Ability.OVERCLOCK:      return "Overclock"
		#Ability.SHANTY:         return "Shanty"
		#_:                      return "Unknown"
#
#func summary() -> String:
	#var trait_names = traits.map(func(t): return trait_name(t))
	#return "%s — %s\nTraits: %s\nAbility: %s\nPower: %d" % [
		#name, role,
		#", ".join(trait_names),
		#ability_name(),
		#stats.total()
	#]
#
#
#
#
#enum JoinType {
	#IMMEDIATE,      # they just want to sail — join on the spot
	#GOLD,           # pay them a signing fee
	#FAVOUR,         # do something for them first (visit a location this island)
	#PROVE_STRENGTH, # beat them in a fight first
	#SHARE_DREAM,    # pass a wit/charisma check — convince them
#}
#
#
#
#class JoinCondition:
	#var type:        JoinType
	#var description: String   # shown to player e.g. "I need someone to clear out the cave first"
	#var resolved:    bool = false
	#var flavour:     String   # what they say when condition is met
#
	#func _init(p_type: JoinType, p_desc: String, p_flavour: String) -> void:
		#type        = p_type
		#description = p_desc
		#flavour     = p_flavour
