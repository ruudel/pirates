extends Control

var _candidates: Array = []

func _ready() -> void:
	TavernManager.tavern_entered.connect(_on_entered)
	TavernManager.tavern_empty.connect(_on_empty)
	TavernManager.recruit_joined.connect(_on_recruit_joined)
	hide()

func open() -> void:
	TavernManager.enter_tavern()

func _on_entered(candidates: Array) -> void:
	_candidates = candidates
	_rebuild()
	show()

func _on_empty() -> void:
	$StatusLabel.text = "The tavern is quiet. No one interesting tonight."
	$CandidateList.hide()
	show()

func _rebuild() -> void:
	for child in $CandidateList.get_children():
		child.queue_free()

	for candidate in _candidates:
		var card = _build_card(candidate)
		$CandidateList.add_child(card)

func _build_card(c: Character) -> PanelContainer:
	var panel = PanelContainer.new()
	var vbox  = VBoxContainer.new()
	panel.add_child(vbox)

	# Name + role
	var name_label = Label.new()
	name_label.text = "%s  —  %s" % [c.name, c.role]
	vbox.add_child(name_label)

	# Stats
	var stats_label = Label.new()
	stats_label.text = "STR %d  NAV %d  LCK %d  RES %d  WIT %d" % [
		c.stats.strength, c.stats.navigation,
		c.stats.luck, c.stats.resilience, c.stats.wit
	]
	vbox.add_child(stats_label)

	# Traits
	var trait_names = c.traits.map(func(t): return c.trait_name(t))
	var traits_label = Label.new()
	traits_label.text = "Traits: " + ", ".join(trait_names)
	vbox.add_child(traits_label)

	# Ability
	var ability_label = Label.new()
	ability_label.text = "Ability: " + c.ability_name()
	vbox.add_child(ability_label)

	# Join condition
	var condition_label = Label.new()
	condition_label.text = "\" " + c.join_condition.description + " \""
	condition_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(condition_label)

	# Recruit button
	var btn = Button.new()
	btn.text = "Recruit"
	btn.pressed.connect(TavernManager.attempt_recruit.bind(c))
	vbox.add_child(btn)

	return panel

func _on_recruit_joined(c: Character) -> void:
	$StatusLabel.text = "%s has joined the crew!" % c.name
	_rebuild()   # remove their card
