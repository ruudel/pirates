extends Control

@onready var header = $Header

func _ready():
	updateUI()

func updateUI():
	#header.get_node("BountyLabel").text = "Crew bounty: " + str(GameManager.BOUNTY)
	#header.get_node("DayLabel").text = "Day: " + str(GameManager.DAY)
	pass
