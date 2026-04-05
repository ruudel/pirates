extends Node

const FIRST_NAMES = [
	"Rowan", "Kael", "Mira", "Finn", "Petra",
	"Dex", "Sable", "Bram", "Yessa", "Niko",
	"Wren", "Cira", "Zola", "Holt", "Sera",
	"Fen", "Thorn", "Lira", "Oryn", "Cade"
]

const LAST_NAMES = [
	"Ashvale", "Stormborn", "Driftwood", "Coldwater", "Blacksail",
	"Wavecrest", "Saltwick", "Ironside", "Greymast", "Seavane",
	"Redmoor", "Coppergate", "Dunmore", "Windhallow", "Tidemark"
]

func generate() -> String:
	return FIRST_NAMES.pick_random() + " " + LAST_NAMES.pick_random()
