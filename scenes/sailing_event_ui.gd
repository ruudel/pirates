# sailing_event_ui.gd — attach to a Control node in WorldView
extends Control

func _ready() -> void:
	SailingManager.sailing_event_triggered.connect(_show_event)
	SailingManager.sailing_arrived.connect(_hide)
	hide()

func _show_event(event: SailingEvent) -> void:
	show()
	$Title.text = event.title
	$Description.text = event.description

	# Clear old choice buttons
	for child in $Choices.get_children():
		child.queue_free()

	# Build choice buttons dynamically
	for i in range(event.choices.size()):
		var choice = event.choices[i]
		var btn    = Button.new()
		btn.text   = choice.label
		btn.pressed.connect(_on_choice.bind(event, i))
		$Choices.add_child(btn)

func _on_choice(event: SailingEvent, index: int) -> void:
	var outcome_label = $OutcomeLabel
	outcome_label.text = event.choices[index].outcome
	outcome_label.show()

	# Hide choices, show outcome briefly then close
	$Choices.hide()
	await get_tree().create_timer(2.5).timeout
	SailingManager.resolve_event(event, index)
	_hide()

func _hide() -> void:
	hide()
	$Choices.show()
	$OutcomeLabel.hide()
