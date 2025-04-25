extends Node3D

@export var gameScene: PackedScene
@export var mainMenuScene: PackedScene

const SAVE_FILE_NAME = "highscore.json"

var highScore = 0
var save_path = ""

func _ready():
    save_path = OS.get_user_data_dir().path_join(SAVE_FILE_NAME)
    load_high_score()
    print("High Score loaded:", highScore)

func save_high_score(new_high_score):
    if new_high_score > highScore:
        highScore = new_high_score
        var save_data = {"highScore": highScore}

        var file = FileAccess.open(save_path, FileAccess.WRITE)
        if file:
            var json_string = JSON.stringify(save_data)
            file.store_line(json_string)
            file.close()
            print("High Score saved:", highScore)
        else:
            printerr("Error opening save file for writing:", save_path)

func load_high_score():
    var file = FileAccess.open(save_path, FileAccess.READ)
    if file:
        var json_string = file.get_line()
        file.close()

        if not json_string.is_empty():
            var save_data = JSON.parse_string(json_string)
            if save_data and save_data.has("highScore"):
                highScore = save_data["highScore"]
            else:
                print("Save file corrupted or missing 'highScore' key.")
        else:
            print("Save file is empty.")
    else:
        print("Save file not found, using default high score.")

# Example of how you might use these functions in your game logic
func _on_game_over(final_score):
    save_high_score(final_score)

func get_current_high_score():
    return highScore

func startGame():
    SceneSwicther.switchScene(gameScene)

func mainMenu():
    SceneSwicther.switchScene(mainMenuScene)