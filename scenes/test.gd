extends Control

func _ready() -> void:
	$Footer/MenuBar/CrewButton.pressed.connect($Cinematic/CrewPanel.open)
	CrewManager.crew_changed.connect(_update_header)
	_update_header()

func _update_header() -> void:
	$Header/BountyLabel.text = "Crew Bounty: %s" % _format_bounty(CrewManager.total_bounty())

func _format_bounty(value: int) -> String:
	# Format as e.g. "1 500 000 000"
	var s      = str(value)
	var result = ""
	var count  = 0
	for i in range(s.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = " " + result
		result = s[i] + result
		count += 1
	return result + " B"
