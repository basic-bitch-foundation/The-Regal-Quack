extends CharacterBody2D
@export var spd: float = 300
@export var jmpforc: float = -200
@export var gravity: float = 650
@export var maxhp: int = 9
@export var drainrate: float = 0.005 

var hp: int
var bghp: float
var touchingenemy: bool = false
var spawnpoint: Marker2D
var collectlayer: TileMapLayer = null
var isdead: bool = false
var deathtimer: float = 0.0
var iswon: bool = false
var wintimer: float = 0.0

@onready var skull1: Sprite2D
@onready var skull2: Sprite2D  
@onready var skull3: Sprite2D
@onready var animsprite: AnimatedSprite2D
@onready var winpanel: Panel
@onready var wintext: RichTextLabel

@onready var bgmusic: AudioStreamPlayer
@onready var jumpsfx: AudioStreamPlayer
@onready var runsfx: AudioStreamPlayer
@onready var hurtsfx: AudioStreamPlayer
@onready var chickensfx: AudioStreamPlayer
@onready var deathsfx: AudioStreamPlayer
@onready var restartsfx: AudioStreamPlayer
@onready var winsfx: AudioStreamPlayer

func _ready() -> void:
	add_to_group("player")
	hp = maxhp
	bghp = float(maxhp)
	
	spawnpoint = get_tree().current_scene.get_node("SpawnPoint")
	
	skull1 = $UI/Skull1
	skull2 = $UI/Skull2
	skull3 = $UI/Skull3
	animsprite = $AnimatedSprite2D
	winpanel = get_tree().current_scene.find_child("WinPanel", true, false)
	wintext = get_tree().current_scene.find_child("WinText", true, false)
	
	if not winpanel:
		print("ERROR: WinPanel not found at CanvasLayer/UIKING/WinPanel")
	if not wintext:
		print("ERROR: WinText not found at CanvasLayer/UIKING/WinPanel/WinText")
	
	bgmusic = $SFX/BGMusic
	jumpsfx = $SFX/JumpSFX
	runsfx = $SFX/RunSFX
	hurtsfx = $SFX/HurtSFX
	chickensfx = $SFX/ChickenSFX
	deathsfx = $SFX/DeathSFX
	restartsfx = $SFX/RestartSFX
	winsfx = $SFX/WinSFX
	
	if bgmusic:
		bgmusic.play()
	
	if winpanel:
		winpanel.visible = false
	
	updateskulls()
	findlayer()
	connectking()

func connectking() -> void:
	var kingbody = get_tree().current_scene.find_child("KingBody", true, false)
	if kingbody:
		var kingarea = kingbody.find_child("Area2D", true, false)
		if kingarea:
			kingarea.body_entered.connect(_on_king_touched)

func _on_king_touched(body: Node2D) -> void:
	if body == self:
		print("King touched! Calling win()")
		win()

func updateskulls() -> void:
	skull1.visible = (hp >= 1)
	skull2.visible = (hp >= 4)  
	skull3.visible = (hp >= 7)
	
	var camera = $Camera2D
	if camera:
		skull1.global_position = camera.global_position + Vector2(-175, -90)
		skull2.global_position = camera.global_position + Vector2(-150, -90)
		skull3.global_position = camera.global_position + Vector2(-125, -90)

func findlayer() -> void:
	collectlayer = get_tree().current_scene.find_child("Layer2", true, false)
	if not collectlayer:
		collectlayer = get_parent().get_node_or_null("TileMap2/Layer1")

func _physics_process(delta: float) -> void:
	if iswon:
		wintimer -= delta
		if wintimer <= 0.0:
			dorespawn()
		return
		
	if isdead:
		deathtimer -= delta
		if deathtimer <= 0.0:
			dorespawn()
		return
	
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
	
	var inputdir = Input.get_axis("ui_left", "ui_right")
	velocity.x = inputdir * spd
	
	if Input.is_action_just_pressed("ui_jump") and is_on_floor():
		velocity.y = jmpforc
		if jumpsfx:
			jumpsfx.play()
	
	move_and_slide()
	
	if abs(inputdir) > 0.1 and is_on_floor():
		if not runsfx.playing:
			runsfx.play()
	else:
		runsfx.stop()
	
	updateanims(inputdir)
	
	if touchingenemy:
		bghp -= drainrate * (delta * 1000.0)
		bghp = max(bghp, 0.0)
		var newhp: int = int(floor(bghp))
		if newhp != hp:
			hp = newhp
			updateskulls()
			if hurtsfx:
				hurtsfx.play()
			
			if hp <= 0:
				respawn()
	
	if collectlayer:
		checkcollect()

func updateanims(inputdir: float) -> void:
	if inputdir > 0:
		animsprite.flip_h = false
	elif inputdir < 0:
		animsprite.flip_h = true
	
	if iswon:
		animsprite.play("idle")
	elif isdead:
		animsprite.play("death")
	elif touchingenemy:
		animsprite.play("hurt")
	elif not is_on_floor():
		animsprite.play("jump")
	elif abs(inputdir) > 0.1:
		animsprite.play("run")
	else:
		animsprite.play("idle")

func hurt(amount: int) -> void:
	if isdead or iswon:
		return
	
	bghp -= amount
	bghp = max(bghp, 0.0)
	hp = int(floor(bghp))
	updateskulls()
	if hp <= 0:
		respawn()

func respawn() -> void:
	if deathsfx:
		deathsfx.play()
	
	isdead = true
	deathtimer = 1.0
	velocity = Vector2.ZERO
	touchingenemy = false
	runsfx.stop()

func dorespawn() -> void:
	if spawnpoint:
		global_position = spawnpoint.global_position
	
	if restartsfx:
		restartsfx.play()
	
	hp = maxhp
	bghp = float(maxhp)
	isdead = false
	iswon = false
	deathtimer = 0.0
	wintimer = 0.0
	touchingenemy = false
	velocity = Vector2.ZERO
	updateskulls()
	
	if winpanel:
		winpanel.visible = false

func start_damage() -> void:
	if not isdead and not iswon:
		touchingenemy = true

func stop_damage() -> void:
	touchingenemy = false

func win() -> void:
	if isdead or iswon:
		return
		
	print("Win function called!")
	iswon = true
	wintimer = 4.0
	velocity = Vector2.ZERO
	touchingenemy = false
	runsfx.stop()
	
	if winsfx:
		winsfx.play()
	
	if winpanel and wintext:
		print("Showing win message")
		winpanel.visible = true
		wintext.text = "[center][color=gold][wave][font_size=48]VICTORY![/font_size][/wave][/color][/center]\n\n[center][color=white][font_size=24]The warrior has returned to pay respects to his fallen king.[/font_size][/color][/center]\n\n[center][color=yellow][font_size=20][fade]Rest in peace, noble ruler...[/fade][/font_size][/color][/center]"
	else:
		print("ERROR: winpanel or wintext is null!")

func checkcollect() -> void:
	if isdead or iswon:
		return
		
	var playertile = collectlayer.local_to_map(collectlayer.to_local(global_position))
	
	for x in range(-1, 2):
		for y in range(-1, 2):
			var checktile = playertile + Vector2i(x, y)
			var tiledata = collectlayer.get_cell_tile_data(checktile)
			
			if tiledata and tiledata.has_custom_data("type"):
				var tiletype = tiledata.get_custom_data("type")
				
				if tiletype == "chickleg":
					if chickensfx:
						chickensfx.play()
					bghp = min(bghp + 0.5, maxhp)
					hp = int(floor(bghp))
					updateskulls()
					collectlayer.set_cell(checktile, -1)
					return
