extends Node

const FIRST_NAMES = [
	"Ryn", "Kael", "Mira", "Doss", "Petra", "Finn", "Sable", "Oryn",
	"Cade", "Lira", "Bram", "Yessa", "Thorn", "Niko", "Sera", "Juko",
	"Wren", "Holt", "Cira", "Dex", "Zola", "Fen", "Moss", "Elia",
	"Rok", "Vane", "Suri", "Dalt", "Bex", "Cyra", "Olan", "Frey"
]

const LAST_NAMES = [
	"Ashvale", "Stormborn", "Ironfist", "Driftwood", "Coldwater",
	"Blacksail", "Wavecrest", "Dunmore", "Saltwick", "Redmoor",
	"Ironside", "Greymast", "Windhallow", "Coppergate", "Seavane",
	"Brackwater", "Hollowmast", "Cinderport", "Vexholm", "Tidemark"
]

# All traits available to every archetype
const ALL_TRAITS = [
	Character.Trait.BRAVE,
	Character.Trait.CALM,
	Character.Trait.CUNNING,
	Character.Trait.LOYAL,
	Character.Trait.CHEERFUL,
	Character.Trait.STOIC,
	Character.Trait.KIND,
	Character.Trait.RECKLESS,
	Character.Trait.GREEDY,
	Character.Trait.SUSPICIOUS,
	Character.Trait.STUPID,
	Character.Trait.COWARD,
	Character.Trait.SHY,
	Character.Trait.ARROGANT,
	Character.Trait.GLUTTON,
	Character.Trait.LAZY,
	Character.Trait.DISHONEST,
]

# Secret locations — only revealed if specific archetype is in crew
# These are added on top of the island's normal locations
enum SecretLocation {
	HIDDEN_LIBRARY,     # Scholar
	UNDERGROUND_MARKET, # Spy
	SECRET_DOCK,        # Shipwright
	RADIO_TOWER,        # Communicator
	ABANDONED_LAB,      # Engineer
	FESTIVAL_GROUNDS,   # Musician
}

const ARCHETYPES = {
	Character.Archetype.CAPTAIN: {
		role    = "Captain",
		stats   = [5, 3, 3, 4, 4],
		ability = Character.Ability.INSPIRING_ROAR,
		unlocks = [],
		secrets = [],
	},
	Character.Archetype.FIGHTER: {
		role    = "Fighter",
		stats   = [6, 1, 2, 5, 1],
		ability = Character.Ability.POWER_STRIKE,
		unlocks = [IslandNode.LocationType.CAVE, IslandNode.LocationType.RUINS],
		secrets = [],
	},
	Character.Archetype.NAVIGATOR: {
		role    = "Navigator",
		stats   = [2, 6, 3, 2, 5],
		ability = Character.Ability.CHART_COURSE,
		unlocks = [],
		secrets = [],
	},
	Character.Archetype.COOK: {
		role    = "Ship's Cook",
		stats   = [3, 2, 4, 5, 3],
		ability = Character.Ability.RALLY,
		unlocks = [IslandNode.LocationType.TAVERN],
		secrets = [],
	},
	Character.Archetype.DOCTOR: {
		role    = "Doctor",
		stats   = [1, 2, 3, 4, 6],
		ability = Character.Ability.PATCH_UP,
		unlocks = [IslandNode.LocationType.SHRINE],
		secrets = [],
	},
	Character.Archetype.SCOUT: {
		role    = "Scout",
		stats   = [3, 4, 6, 2, 3],
		ability = Character.Ability.AMBUSH,
		unlocks = [],
		secrets = [],
	},
	Character.Archetype.SCHOLAR: {
		role    = "Scholar",
		stats   = [1, 2, 4, 2, 7],
		ability = Character.Ability.ANALYZE,
		unlocks = [IslandNode.LocationType.RUINS],
		secrets = [SecretLocation.HIDDEN_LIBRARY],
	},
	Character.Archetype.SPY: {
		role    = "Spy",
		stats   = [3, 3, 5, 3, 5],
		ability = Character.Ability.VANISH,
		unlocks = [],
		secrets = [SecretLocation.UNDERGROUND_MARKET],
	},
	Character.Archetype.SHIPWRIGHT: {
		role    = "Shipwright",
		stats   = [4, 3, 2, 5, 3],
		ability = Character.Ability.REINFORCE,
		unlocks = [],
		secrets = [SecretLocation.SECRET_DOCK],
	},
	Character.Archetype.COMMUNICATOR: {
		role    = "Communicator",
		stats   = [2, 3, 4, 2, 6],
		ability = Character.Ability.BROADCAST,
		unlocks = [],
		secrets = [SecretLocation.RADIO_TOWER],
	},
	Character.Archetype.ENGINEER: {
		role    = "Engineer",
		stats   = [3, 4, 3, 4, 4],
		ability = Character.Ability.OVERCLOCK,
		unlocks = [],
		secrets = [SecretLocation.ABANDONED_LAB],
	},
	Character.Archetype.MUSICIAN: {
		role    = "Musician",
		stats   = [2, 2, 6, 3, 4],
		ability = Character.Ability.SHANTY,
		unlocks = [IslandNode.LocationType.TAVERN],
		secrets = [SecretLocation.FESTIVAL_GROUNDS],
	},
}

func generate(archetype: Character.Archetype) -> Character:
	var c         = Character.new()
	var blueprint = ARCHETYPES[archetype]

	c.id        = _uid()
	c.name      = _random_name()
	c.archetype = archetype
	c.role      = blueprint.role
	c.ability   = blueprint.ability
	c.unlocks   = blueprint.unlocks.duplicate()
	c.secrets   = blueprint.secrets.duplicate()

	var s = blueprint.stats
	c.stats = Character.StatBlock.new(
		_vary(s[0]), _vary(s[1]), _vary(s[2]), _vary(s[3]), _vary(s[4])
	)

	# All archetypes draw from the full trait pool
	# Weighted so negative traits are less common but possible
	c.traits = _pick_traits(2)

	return c

func generate_player() -> Character:
	var c       = generate(Character.Archetype.CAPTAIN)
	c.name      = "You"
	c.is_player = true
	return c

func generate_random_crew_candidate() -> Character:
	var pool = [
		Character.Archetype.FIGHTER,
		Character.Archetype.NAVIGATOR,
		Character.Archetype.COOK,
		Character.Archetype.DOCTOR,
		Character.Archetype.SCOUT,
		Character.Archetype.SCHOLAR,
		Character.Archetype.SPY,
		Character.Archetype.SHIPWRIGHT,
		Character.Archetype.COMMUNICATOR,
		Character.Archetype.ENGINEER,
		Character.Archetype.MUSICIAN,
	]
	pool.shuffle()
	var c = generate(pool[0])
	c.is_recruit     = true
	c.join_condition = generate_join_condition(c)
	return c

func generate_join_condition(_c: Character) -> Character.JoinCondition:
	# Archetype is intentionally ignored here
	# People join for personal reasons, not professional ones
	var all_conditions = [

		# Just ready to leave
		Character.JoinCondition.new(Character.JoinType.IMMEDIATE,
			"I've been stuck on this island for three months. Get me out of here.",
			"Finally. Let's go before I change my mind."),

		Character.JoinCondition.new(Character.JoinType.IMMEDIATE,
			"I heard what you did at the port. That's the kind of captain I want to sail under.",
			"Don't make me regret this."),

		Character.JoinCondition.new(Character.JoinType.IMMEDIATE,
			"I've got nothing left here. Not anymore.",
			"...Let's just sail."),

		Character.JoinCondition.new(Character.JoinType.IMMEDIATE,
			"I made a bet with myself — first captain who walked in and ordered honestly, I'd follow them. That was you.",
			"Weird reason, I know. I stand by it."),

		# Gold — but for personal reasons
		Character.JoinCondition.new(Character.JoinType.GOLD,
			"I have a debt to settle before I go anywhere. Help me clear it and I'm yours.",
			"That's the last of it. I'm free. Let's sail."),

		Character.JoinCondition.new(Character.JoinType.GOLD,
			"My younger brother needs money for medicine. I'm not leaving until he's taken care of.",
			"He'll be alright now. Thank you. I mean it."),

		Character.JoinCondition.new(Character.JoinType.GOLD,
			"I'll join any crew that can afford to feed me properly. Can you?",
			"Good enough. I eat a lot, fair warning."),

		# Favours — all personal
		Character.JoinCondition.new(Character.JoinType.FAVOUR,
			"Someone on this island has something that belongs to my family. I need it back before I can leave.",
			"That's mine again. I've been looking for it for two years."),

		Character.JoinCondition.new(Character.JoinType.FAVOUR,
			"There's a person in this town I need to say goodbye to properly. Help me find them first.",
			"I said what I needed to say. Okay. I'm ready."),

		Character.JoinCondition.new(Character.JoinType.FAVOUR,
			"I need someone to check on my neighbour after I'm gone. Old woman, lives near the shrine. Just make sure she's alright.",
			"You actually went. Good. Now I can leave without it weighing on me."),

		Character.JoinCondition.new(Character.JoinType.FAVOUR,
			"There's a man at the docks who's been threatening the locals. I won't leave until someone deals with him.",
			"Word got around fast. Thank you. This place can breathe again."),

		Character.JoinCondition.new(Character.JoinType.FAVOUR,
			"I lost something in the ruins outside town. I've been too scared to go back alone.",
			"You found it. I didn't think... thank you. Truly."),

		# Prove yourself — but not always combat
		Character.JoinCondition.new(Character.JoinType.PROVE_STRENGTH,
			"I've followed weak captains my whole life. Show me you're different.",
			"Alright. You're the real thing."),

		Character.JoinCondition.new(Character.JoinType.PROVE_STRENGTH,
			"Everyone who comes through here says they're going to make it to the end. Prove you mean it.",
			"Most people flinch when I ask that. You didn't."),

		# Share your dream — the most personal of all
		Character.JoinCondition.new(Character.JoinType.SHARE_DREAM,
			"I've been waiting for someone going somewhere worth going. Where are you headed, and why?",
			"That's the first honest answer I've heard in years. I'm in."),

		Character.JoinCondition.new(Character.JoinType.SHARE_DREAM,
			"My last captain lied to me about what we were sailing toward. Tell me the truth about yours.",
			"You didn't dress it up. I respect that more than you know."),

		Character.JoinCondition.new(Character.JoinType.SHARE_DREAM,
			"I used to have a dream like that. I gave up on it. Maybe sailing with you I'll remember why it mattered.",
			"...Don't let me forget again."),

		Character.JoinCondition.new(Character.JoinType.SHARE_DREAM,
			"My father told me to find a crew worth dying for before I turned thirty. I'm running out of time.",
			"I think you might be it."),
	]

	all_conditions.shuffle()
	return all_conditions[0]
	
func _condition_pool_for(archetype: Character.Archetype) -> Array:
	# Each archetype has a weighted pool — listed with duplicates for weight
	match archetype:
		Character.Archetype.FIGHTER:
			return [
				Character.JoinType.PROVE_STRENGTH,
				Character.JoinType.PROVE_STRENGTH,
				Character.JoinType.IMMEDIATE,
				Character.JoinType.FAVOUR,
			]
		Character.Archetype.NAVIGATOR:
			return [
				Character.JoinType.SHARE_DREAM,
				Character.JoinType.SHARE_DREAM,
				Character.JoinType.GOLD,
				Character.JoinType.IMMEDIATE,
			]
		Character.Archetype.COOK:
			return [
				Character.JoinType.IMMEDIATE,
				Character.JoinType.IMMEDIATE,
				Character.JoinType.FAVOUR,
				Character.JoinType.SHARE_DREAM,
			]
		Character.Archetype.DOCTOR:
			return [
				Character.JoinType.FAVOUR,
				Character.JoinType.FAVOUR,
				Character.JoinType.SHARE_DREAM,
				Character.JoinType.IMMEDIATE,
			]
		Character.Archetype.SPY:
			return [
				Character.JoinType.GOLD,
				Character.JoinType.GOLD,
				Character.JoinType.FAVOUR,
				Character.JoinType.IMMEDIATE,
			]
		Character.Archetype.SCHOLAR:
			return [
				Character.JoinType.SHARE_DREAM,
				Character.JoinType.FAVOUR,
				Character.JoinType.IMMEDIATE,
				Character.JoinType.GOLD,
			]
		_:
			return [
				Character.JoinType.IMMEDIATE,
				Character.JoinType.GOLD,
				Character.JoinType.SHARE_DREAM,
				Character.JoinType.FAVOUR,
			]

class _Favour:
	var description: String
	var flavour:     String
	func _init(d: String, f: String) -> void:
		description = d
		flavour     = f

func _favours_for(archetype: Character.Archetype) -> Array:
	# Favour content is flavoured by archetype
	match archetype:
		Character.Archetype.FIGHTER:
			return [
				_Favour.new(
					"There's a man in the cave east of town who took something from me. Get it back.",
					"You actually did it. Alright, I owe you one."
				),
				_Favour.new(
					"Clear out whatever's been scaring the locals at the ruins. Then we'll talk.",
					"Word travels fast. Come find me at the dock."
				),
			]
		Character.Archetype.DOCTOR:
			return [
				_Favour.new(
					"There's a sick child in this town and I'm missing one ingredient. Find it at the market.",
					"You saved that kid. I'll go wherever you're going."
				),
				_Favour.new(
					"Someone at the shrine has information I need. Go ask them — they won't talk to me.",
					"That's everything I needed. I'm in your debt."
				),
			]
		Character.Archetype.COOK:
			return [
				_Favour.new(
					"I need a specific spice from the market. The merchant is stubborn — see what you can do.",
					"You got it. I'll cook something worthy of the occasion."
				),
			]
		Character.Archetype.MUSICIAN:
			return [
				_Favour.new(
					"I left my instrument with someone at the shrine for safekeeping. They're refusing to give it back.",
					"That's mine again. Let's make some music on the open water."
				),
			]
		_:
			return [
				_Favour.new(
					"Do something for me first. Ask around town — you'll figure out what.",
					"I heard what you did. You're alright."
				),
			]

# ── helpers ───────────────────────────────────────────────────────────────────

func _pick_traits(count: int) -> Array:
	# Positive/neutral traits are roughly twice as likely as negative ones
	var weighted = []
	for t in ALL_TRAITS:
		weighted.append(t)
		if t not in [
			Character.Trait.STUPID, Character.Trait.COWARD,
			Character.Trait.SHY, Character.Trait.ARROGANT,
			Character.Trait.GLUTTON, Character.Trait.LAZY,
			Character.Trait.DISHONEST
		]:
			weighted.append(t)  # add positive traits twice = double weight

	weighted.shuffle()
	var picked = []
	for t in weighted:
		if t not in picked:
			picked.append(t)
		if picked.size() >= count:
			break
	return picked

func _random_name() -> String:
	return FIRST_NAMES.pick_random() + " " + LAST_NAMES.pick_random()

func _vary(base: int) -> int:
	return clampi(base + randi_range(-1, 1), 1, 10)

func _uid() -> String:
	return str(randi()) + str(randi())
