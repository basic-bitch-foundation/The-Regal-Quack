extends CanvasLayer

@onready var skull1: TextureRect = $Skull1
@onready var skull2: TextureRect = $Skull2  
@onready var skull3: TextureRect = $Skull3

func _ready() -> void:
	# Make sure we're in the ui group so player can find us
	add_to_group("ui")

func update_skulls(hp: int) -> void:
	print("Updating skulls with HP: ", hp)
	
	if skull3:
		skull3.visible = (hp >= 7)
		
	if skull2:
		skull2.visible = (hp >= 4)
		
	if skull1:
		skull1.visible = (hp >= 1)
