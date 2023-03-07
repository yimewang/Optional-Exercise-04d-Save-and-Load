# Optional-Exercise-04d-Save-and-Load

Exercise for MSCH-C220

A demonstration of this exercise is available at [https://youtu.be/WSBgQ3PBmbA](https://youtu.be/WSBgQ3PBmbA).

This exercise is designed to continue our creation of a 2D Platformer, by demonstrating the wrong and the right (better?) ways to save and load data.

Fork this repository. When that process has completed, make sure that the top of the repository reads [your username]/Optional-Exercise-04d-Save-and-Load. *Edit the LICENSE and replace BL-MSCH-C220 with your full name.* Commit your changes.

Clone the repository to a Local Path on your computer.

There are two folders in this repository, each with a complete Godot project.

Open Godot. Navigate to the 01-Config folder. Import the project.godot file and open the "Save and Load: Config" project.

This project implements save an load using a config file. This is certainly an easy way to save data, but it has some important limitations (which is why it should only be used to save configuration information).

Open Global.gd, and replace the `save_game()` and `load_game()` methods with the following (starting on line 58):
```
func save_game():
	save_data["general"]["coins"] = []					# creating a list of all the coins that appear in the scene
	save_data["general"]["mines"] = []					# creating a list of all the mines in the scene
	for c in Coins.get_children():						# returns a list of all the nodes in /Game/Coins
		save_data["general"]["coins"].append(c.position)		# adds the coins to the list
	for m in Mines.get_children():
		save_data["general"]["mines"].append(m.position)
	for section in save_data.keys():					# Go through all the coins and mines and add them as keys to the config file
		for key in save_data[section]:
			save_file.set_value(section, key, save_data[section][key])
	save_file.save(SAVE_PATH)						# write the data to the config file

func load_game():
	var error = save_file.load(SAVE_PATH)					# load the keys out of the config file
	if error != OK:								# if there's a problem reading the file, print an error
		print("Failed loading file")
		return
	
	save_data["general"]["coins"] = []					# initialize a list to temporarily hold the coins and mines
	save_data["general"]["mines"] = []
	for section in save_data.keys():
		for key in save_data[section]:					# go through everything in the config file and add it to the lists
			save_data[section][key] = save_file.get_value(section, key, null)
	var _scene = get_tree().change_scene_to(Game)				# reset the scene
	call_deferred("restart_level")						# when the scene has been loaded, call the reset_level method
```

Save your project and test it. Blow up a few mines and collect a few coins. Press escape to access the menu, and then save your game. Press the load button and watch what happens. Repeat a few times.

Now, look at the files again in the Windows Explorer or the System Finder. You should see a new file in the 01 Config folder: settings.cfg. Open that file with some kind of text editor and take a look at it. What would happen if you were to edit this file directly?

In the file, change both the score and lives values to 1000. Save your changes and close the file. Go back to Godot and run your project; load your game. What happened?

Now, it's time to do it the right way. Open the 02-Save folder and import the Godot project. Open Global.gd in the Save and Load: Save File project, and replace the `save_game()` and `load_game()` methods (line 58) with the following:
```
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
		save_data = result_json.result_json				# If so, load the data from the file into the save_data lists
	else:
		print("Error: ", result_json.error)
	save_game.close()							# Close the file so other processes can read from or write to it
	
	var _scene = get_tree().change_scene_to(Game)				# Load the scene
	call_deferred("restart_level")						# When it's done being loaded, call the restart_level method
```

Now, instead of using a config file, we are using an actual save file in user space (instead of in the application itself). Also, we are encrypting the file using the SECRET passphrase. Depending on your operating system, that file is stored in one of the following locations:
```
Windows: C:\Users\<username>\AppData\Roaming\Godot\app_userdata\<project>\
MacOS: ~/Library/Application\ Support/Godot/app_userdata/_APPLICATION_NAME_
Unix: ~/.local/share/godot/app_userdata/_application_name_/
```

Test the game and play with the save and load functionality.

Quit Godot. In GitHub desktop, add a summary message, commit your changes and push them back to GitHub. If you return to and refresh your GitHub repository page, you should now see your updated files with the time when they were changed.

Now edit the README.md file. When you have finished editing, commit your changes, and then turn in the URL of the main repository page (https://github.com/[username]/Optional-Exercise-04d-Save-and-Load) on Canvas.

The final state of the file should be as follows (replacing the "Created by" information with your name):
```
# Optional-Exercise-04d-Save-and-Load

Exercise for MSCH-C220

The fourth exercise for the 2D Platformer project, exploring save and load (in two projects).

## Implementation

Built using Godot 3.5

The player sprite is an adaptation of [MV Platformer Male](https://opengameart.org/content/mv-platformer-male-32x64) by MoikMellah. CC0 Licensed.

The coin sprite is provided by Kenney.nl: [https://kenney.nl/assets/puzzle-pack-2](https://kenney.nl/assets/puzzle-pack-2).

The explosion animation is also adapted from Kenney.nl: [https://kenney.nl/assets/tanks](https://kenney.nl/assets/tanks).


## References

For more information about save and load in Godot, visit the Godot documentation: [https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html#saving-and-reading-data](https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html#saving-and-reading-data)


## Future Development

None

## Grading

If you would like the points from this exercise to replace a previous exercise or count toward a project or the midterm, indicate that here:

Which Exercise should this replace?

*or* 

Which project should these points be applied toward?

*or*

Should the points from this exercise be applied to the midterm?

## Created by 

Jason Francis
```
