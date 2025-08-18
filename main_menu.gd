extends Control
@export var gamescene: String = ""

@onready var playbtn: TextureButton = $PlayButton
@onready var htpbtn: TextureButton = $HowToPlayButton
@onready var htppanel: Panel = $HowToPlayButton/HowToPlayPanel
@onready var closebtn: Button = $HowToPlayButton/HowToPlayPanel/CloseButton
@onready var guidetxt: RichTextLabel = $HowToPlayButton/HowToPlayPanel/GuideLabel

func _ready():
	playbtn.pressed.connect(startgame)
	htpbtn.pressed.connect(showhelp)
	closebtn.pressed.connect(closehelp)
	htppanel.visible = false

func startgame():
	if gamescene != "":
		get_tree().change_scene_to_file(gamescene)

func showhelp():
	htppanel.visible = true

func closehelp():
	htppanel.visible = false
