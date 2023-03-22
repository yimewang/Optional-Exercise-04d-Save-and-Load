extends Node

const SAVE_PATH = "user://savegame.sav"
const SECRET = "C220 Is the Best!"
var save_file = ConfigFile.new()

onready var HUD = get_node_or_null("/root/Game/UI/HUD")
onready var Coins = get_node_or_null("/root/Game/Coins")
onready var Mines = get_node_or_null("/root/Game/Mines")
onready var Game = load("res://Game.tscn")
onready var Coin = load("res://Coin/Coin.tscn")
onready var Mine = load("res://Mine/Mine.tscn")

var save_data = {
	"general": {
		"score":0
		,"health":100
		,"coins":[]
		,"mines":[]	
	}
}


func _ready():
	update_score(0)
	update_health(0)

func update_score(s):
	save_data["general"]["score"] += s
	HUD.find_node("Score").text = "Score: " + str(save_data["general"]["score"])

func update_health(h):
	save_data["general"]["health"] += h
	HUD.find_node("Health").text = "Health: " + str(save_data["general"]["health"])

func restart_level():
	HUD = get_node_or_null("/root/Game/UI/HUD")
	Coins = get_node_or_null("/root/Game/Coins")
	Mines = get_node_or_null("/root/Game/Mines")
	
	for c in Coins.get_children():
		c.queue_free()
	for m in Mines.get_children():
		m.queue_free()
	for c in save_data["general"]["coins"]:
		var coin = Coin.instance()
		coin.position = str2var(c)
		Coins.add_child(coin)
	for m in save_data["general"]["mines"]:
		var mine = Mine.instance()
		mine.position = str2var(m)
		Mines.add_child(mine)
	update_score(0)
	update_health(0)
	get_tree().paused = false

# ----------------------------------------------------------
	
func save_game():
	save_data["general"]["coins"] = []					# creating a list of all the coins and mines that appear in the scene
	save_data["general"]["mines"] = []
	for c in Coins.get_children():
		save_data["general"]["coins"].append(var2str(c.position))	# get a json representation of each of the coins
	for m in Mines.get_children():
		save_data["general"]["mines"].append(var2str(m.position))	# and mines

	var save_game = File.new()						# create a new file object
	save_game.open_encrypted_with_pass(SAVE_PATH, File.WRITE, SECRET)	# prep it for writing to, make sure the contents are encrypted
	save_game.store_string(to_json(save_data))				# convert the data to a json representation and write it to the file
	save_game.close()							# close the file so other processes can read from or write to it
	
func load_game():
	var save_game = File.new()						# Create a new file object
	if not save_game.file_exists(SAVE_PATH):				# If it doesn't exist, skip the rest of the function
		return
	save_game.open_encrypted_with_pass(SAVE_PATH, File.READ, SECRET)	# The file should be encrypted
	var contents = save_game.get_as_text()					# Get the contents of the file
	var result_json = JSON.parse(contents)					# And parse the JSON
	if result_json.error == OK:						# Check to make sure the JSON got successfully parsed
		save_data = result_json.result				# If so, load the data from the file into the save_data lists
	else:
		print("Error: ", result_json.error)
	save_game.close()							# Close the file so other processes can read from or write to it
	
	var _scene = get_tree().change_scene_to(Game)				# Load the scene
	call_deferred("restart_level")						# When it's done being loaded, call the restart_level method
