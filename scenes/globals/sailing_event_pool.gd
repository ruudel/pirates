extends Node

# ── public ───────────────────────────────────────────────────────────────────

func get_event(grand_line: bool = false) -> SailingEvent:
	var pool = GRAND_LINE_EVENTS if grand_line else NORMAL_EVENTS
	# Filter out events that require crew members not present
	var valid = pool.filter(func(e): return _crew_satisfies(e))
	if valid.is_empty():
		return null
	valid.shuffle()
	return valid[0]

func roll_event_count() -> int:
	# 40% none, 40% one, 20% two
	var r = randf()
	if r < 0.4:  return 0
	if r < 0.8:  return 1
	return 2

# ── helpers ──────────────────────────────────────────────────────────────────

func _crew_satisfies(e: SailingEvent) -> bool:
	if e.requires.is_empty():
		return true
	for archetype in e.requires:
		for m in CrewManager.members:
			if m.archetype == archetype:
				return true
	return false

func _e(id: String, cat: SailingEvent.Category, title: String, desc: String,
		choices: Array, requires: Array = []) -> SailingEvent:
	var e        = SailingEvent.new()
	e.id         = id
	e.category   = cat
	e.title      = title
	e.description = desc
	e.choices    = choices
	e.requires   = requires
	return e

func _c(label: String, outcome: String,
		effect: SailingEvent.Effect = SailingEvent.Effect.NONE,
		value: int = 0) -> SailingEvent.EventChoice:
	return SailingEvent.EventChoice.new(label, outcome, effect, value)

# ── event pools ──────────────────────────────────────────────────────────────

var NORMAL_EVENTS: Array

var GRAND_LINE_EVENTS: Array

func _ready() -> void:
	NORMAL_EVENTS = [

		# ── CREW MOMENTS ─────────────────────────────────────────────────────

		_e("cm_argument", SailingEvent.Category.CREW_MOMENT,
			"Heated Words",
			"Two of your crew are at each other's throats on the deck. The tension has been building for days.",
			[
				_c("Let them sort it out",
				   "They settle it themselves. A little rougher, a little more honest.",
				   SailingEvent.Effect.NONE),
				_c("Step in and mediate",
				   "You cool things down. The crew respects the call.",
				   SailingEvent.Effect.STAT_BUFF, 1),
				_c("Make them spar it out",
				   "They fight, laugh, and move on. Morale lifts.",
				   SailingEvent.Effect.STAT_BUFF, 2),
			]
		),

		_e("cm_story", SailingEvent.Category.CREW_MOMENT,
			"A Story from Before",
			"One of your crew sits at the bow, watching the horizon. They start talking about where they came from.",
			[
				_c("Listen closely",
				   "You learn something about them you didn't know. The crew feels a little closer.",
				   SailingEvent.Effect.STAT_BUFF, 1),
				_c("Give them space",
				   "They nod, grateful. Some things are private.",
				   SailingEvent.Effect.NONE),
			]
		),

		_e("cm_musician", SailingEvent.Category.CREW_MOMENT,
			"A Song on the Wind",
			"Your musician pulls out their instrument as the sun sets. The whole crew gathers without a word.",
			[
				_c("Let them play",
				   "The song carries across the water. Everyone sleeps better that night.",
				   SailingEvent.Effect.STAT_BUFF, 2),
			],
			[Character.Archetype.MUSICIAN]
		),

		_e("cm_cook_feast", SailingEvent.Category.CREW_MOMENT,
			"Something Smells Good",
			"Your cook has been in the galley for hours. They emerge with something extraordinary.",
			[
				_c("Eat well",
				   "The crew is fed and happy. Resilience up across the board.",
				   SailingEvent.Effect.STAT_BUFF, 3),
				_c("Save some for later",
				   "Smart thinking. You gain provisions.",
				   SailingEvent.Effect.GAIN_RESOURCE, 2),
			],
			[Character.Archetype.COOK]
		),

		_e("cm_homesick", SailingEvent.Category.CREW_MOMENT,
			"Homesick",
			"One of your crew has been quiet for days. You find them staring at a letter they've read a hundred times.",
			[
				_c("Sit with them",
				   "You don't say much. You don't need to.",
				   SailingEvent.Effect.STAT_BUFF, 1),
				_c("Remind them why they're here",
				   "They straighten up. The dream is bigger than homesickness.",
				   SailingEvent.Effect.NONE),
				_c("Ignore it",
				   "They'll shake it off. Probably.",
				   SailingEvent.Effect.STAT_DEBUFF, 1),
			]
		),

		# ── WEATHER ──────────────────────────────────────────────────────────

		_e("wx_storm", SailingEvent.Category.WEATHER,
			"Storm on the Horizon",
			"Black clouds are building fast. You have maybe an hour before it hits.",
			[
				_c("Push through it",
				   "The ship takes a beating but you gain time.",
				   SailingEvent.Effect.LOSE_RESOURCE, 2),
				_c("Reef the sails and ride it out",
				   "Slow going, but the ship holds together.",
				   SailingEvent.Effect.NONE),
				_c("Find shelter in a nearby cove",
				   "You lose half a day but arrive in perfect shape.",
				   SailingEvent.Effect.GAIN_RESOURCE, 1),
			]
		),

		_e("wx_dead_calm", SailingEvent.Category.WEATHER,
			"Dead Calm",
			"The wind has completely died. The sea is a mirror. The ship barely drifts.",
			[
				_c("Use the oars",
				   "The crew rows in shifts. Exhausting but effective.",
				   SailingEvent.Effect.STAT_DEBUFF, 1),
				_c("Wait for the wind",
				   "You drift and rest. Everyone recovers but time is lost.",
				   SailingEvent.Effect.STAT_BUFF, 1),
				_c("Have the navigator find a current",
				   "They locate a deep current that carries you forward.",
				   SailingEvent.Effect.NONE),
			],
			[Character.Archetype.NAVIGATOR]
		),

		_e("wx_fog", SailingEvent.Category.WEATHER,
			"Sea Fog",
			"A thick fog rolls in without warning. You can barely see the bow from the stern.",
			[
				_c("Slow down and proceed carefully",
				   "Safe but slow. Nothing happens.",
				   SailingEvent.Effect.NONE),
				_c("Trust the navigator",
				   "They guide you through by instinct alone. Impressive.",
				   SailingEvent.Effect.STAT_BUFF, 2),
				_c("Ring the bell and push forward",
				   "Bold. You clip something in the fog. Minor damage.",
				   SailingEvent.Effect.LOSE_RESOURCE, 1),
			]
		),

		# ── ENCOUNTERS ───────────────────────────────────────────────────────

		_e("enc_pirate", SailingEvent.Category.ENCOUNTER,
			"Hostile Sails",
			"A ship is closing fast, cannons run out. Pirates — or maybe marines. Either way, they want a fight.",
			[
				_c("Fight them",
				   "You engage. Win or lose, there will be blood.",
				   SailingEvent.Effect.NONE),   # hooks into combat later
				_c("Try to outrun them",
				   "The chase is long. You gain distance but lose supplies.",
				   SailingEvent.Effect.LOSE_RESOURCE, 2),
				_c("Bluff — raise a false flag",
				   "They hesitate just long enough. You slip away.",
				   SailingEvent.Effect.NONE),
			]
		),

		_e("enc_sea_creature", SailingEvent.Category.ENCOUNTER,
			"Something Below",
			"The water around the ship has gone dark. Something very large is moving underneath you.",
			[
				_c("Stay perfectly still",
				   "It passes beneath you and disappears into the deep.",
				   SailingEvent.Effect.NONE),
				_c("Drive it off with noise",
				   "It retreats, annoyed. The crew is shaken but safe.",
				   SailingEvent.Effect.STAT_DEBUFF, 1),
				_c("Try to study it",
				   "Your scholar sketches furiously. Fascinating.",
				   SailingEvent.Effect.STAT_BUFF, 1),
			]
		),

		_e("enc_merchant", SailingEvent.Category.ENCOUNTER,
			"Merchant Vessel",
			"A heavily loaded merchant ship waves you down. They want to trade.",
			[
				_c("Trade fairly",
				   "You exchange goods at market price. Both crews part happy.",
				   SailingEvent.Effect.GAIN_RESOURCE, 2),
				_c("Demand a better rate",
				   "They grumble but agree. Good haul.",
				   SailingEvent.Effect.GAIN_RESOURCE, 4),
				_c("Rob them",
				   "Easy pickings. Great haul but the crew's conscience stirs.",
				   SailingEvent.Effect.GAIN_RESOURCE, 6),
				_c("Wave them on",
				   "Not worth the time.",
				   SailingEvent.Effect.NONE),
			]
		),

		# ── DISCOVERY ────────────────────────────────────────────────────────

		_e("disc_wreckage", SailingEvent.Category.DISCOVERY,
			"Floating Wreckage",
			"The remains of a ship drift past — mast, barrels, and what looks like a sealed chest.",
			[
				_c("Pull it aboard",
				   "You haul up supplies and something interesting.",
				   SailingEvent.Effect.GAIN_RESOURCE, 3),
				_c("Leave it",
				   "Bad luck to take from the dead.",
				   SailingEvent.Effect.NONE),
				_c("Search for survivors",
				   "You find one. They're barely alive but grateful.",
				   SailingEvent.Effect.NONE),  # potential crew recruit hook
			]
		),

		_e("disc_bottle", SailingEvent.Category.DISCOVERY,
			"Message in a Bottle",
			"A bottle bobs against the hull. Inside is a water-stained map and three words: 'Don't come here.'",
			[
				_c("Study the map",
				   "Your scholar identifies a location not on any known chart.",
				   SailingEvent.Effect.NONE),  # secret island hook
				_c("Throw it back",
				   "Some warnings are worth heeding.",
				   SailingEvent.Effect.NONE),
			]
		),

		_e("disc_stowaway", SailingEvent.Category.DISCOVERY,
			"Stowaway",
			"A crash from below deck. Someone has been hiding in the cargo hold for two days.",
			[
				_c("Let them join the crew",
				   "They're desperate and capable. Could be useful.",
				   SailingEvent.Effect.NONE),   # crew recruit hook
				_c("Drop them at the next island",
				   "Fair enough. They don't argue.",
				   SailingEvent.Effect.NONE),
				_c("Put them to work immediately",
				   "They earn their keep. Extra hands help.",
				   SailingEvent.Effect.GAIN_RESOURCE, 1),
			]
		),
	]

	GRAND_LINE_EVENTS = [

		_e("gl_logpose", SailingEvent.Category.GRAND_LINE,
			"The Log Pose Trembles",
			"The needle on your log pose is spinning. Not pointing. Spinning. The next island is close — or angry.",
			[
				_c("Trust the pose",
				   "It steadies after an hour. You stay the course.",
				   SailingEvent.Effect.NONE),
				_c("Ask the navigator",
				   "They've seen this before. Barely. You adjust course slightly.",
				   SailingEvent.Effect.STAT_BUFF, 1),
			]
		),

		_e("gl_voice", SailingEvent.Category.GRAND_LINE,
			"A Voice from the Water",
			"In the dead of night, someone hears a voice coming from beneath the hull. It knows your name.",
			[
				_c("Ignore it",
				   "It stops before dawn. The crew doesn't sleep well.",
				   SailingEvent.Effect.STAT_DEBUFF, 1),
				_c("Answer it",
				   "Silence. Then a single word back: 'Soon.'",
				   SailingEvent.Effect.NONE),
			]
		),

		_e("gl_weather", SailingEvent.Category.GRAND_LINE,
			"Impossible Weather",
			"It is snowing on one side of the ship. On the other side, the sea is on fire.",
			[
				_c("Sail straight through",
				   "The Grand Line doesn't care about your comfort.",
				   SailingEvent.Effect.LOSE_RESOURCE, 1),
				_c("Find the safe corridor",
				   "Your navigator threads the needle perfectly.",
				   SailingEvent.Effect.NONE),
			]
		),

		_e("gl_giant", SailingEvent.Category.GRAND_LINE,
			"Giant on the Horizon",
			"A figure the size of a small island is wading through the sea ahead of you.",
			[
				_c("Give it a very wide berth",
				   "You lose time but arrive intact.",
				   SailingEvent.Effect.NONE),
				_c("Sail closer — this is history",
				   "It ignores you completely. Terrifying. Magnificent.",
				   SailingEvent.Effect.STAT_BUFF, 2),
			]
		),
	]
