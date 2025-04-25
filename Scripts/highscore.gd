extends Node

const SAVE_FILE_NAME = "highscore.json"

var high_score = 0
var save_path = ""

func _ready():
	save_path = OS.get_user_data_dir().path_join(SAVE_FILE_NAME)
	load_high_score()
	print("High Score loaded:", high_score)

func save_high_score(new_high_score):
	if new_high_score > high_score:
		high_score = new_high_score
		var save_data = {"high_score": high_score}

		var file = FileAccess.open(save_path, FileAccess.WRITE)
		if file:
			var json_string = JSON.stringify(save_data)
			file.store_line(json_string)
			file.close()
			print("High Score saved:", high_score)
		else:
			printerr("Error opening save file for writing:", save_path)

func load_high_score():
	var file = FileAccess.open(save_path, FileAccess.READ)
	if file:
		var json_string = file.get_line()
		file.close()

		if not json_string.is_empty():
			var save_data = JSON.parse_string(json_string)
			if save_data and save_data.has("high_score"):
				high_score = save_data["high_score"]
			else:
				print("Save file corrupted or missing 'high_score' key.")
		else:
			print("Save file is empty.")
	else:
		print("Save file not found, using default high score.")

# Example of how you might use these functions in your game logic
func _on_game_over(final_score):
	save_high_score(final_score)

func get_current_high_score():
	return high_score