extends Node3D

@onready var title = $"Menu UI/Title"
@onready var buttons = $"Menu UI/Buttons"

@onready var playButton = $"Menu UI/Buttons/Play"
@onready var highscoreButton = $"Menu UI/Buttons/Highscore"
@onready var quitButton = $"Menu UI/Buttons/Quit"

@onready var highscorePopUp = $"Menu UI/highscorePage"
@onready var highscoreExitButton = $"Menu UI/highscorePage/Exit"
@onready var highscoreText = $"Menu UI/highscorePage/HBoxContainer/highscoreValue"

@onready var root = get_tree().current_scene


func _ready(): 
	playButton.button_up.connect(playGame)
	quitButton.button_up.connect(quitGame) 
	highscoreButton.button_up.connect(showHighscore) 
	highscoreExitButton.button_up.connect(hideHighscore)


func playGame():
	get_parent().startGame()
	# for child in get_children():
	#     child.active = false

func quitGame():
	get_tree().quit()

func hideHighscore():
	highscorePopUp.visible = false

	title.visible = true
	buttons.visible = true

func showHighscore():
	title.visible = false
	buttons.visible = false

	highscorePopUp.visible = true
	if root.highScore > 0:
		highscoreText.text = str(root.highScore) + " Waves"
	else:
		highscoreText.text = "-"
