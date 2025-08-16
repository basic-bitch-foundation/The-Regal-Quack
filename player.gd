extends CharacterBody2D

@export var spd := 400
@export var jmp_forc := -300
@export var gravity := 600
@export var maxhp := 10

var hp := maxhp

func _ready():
	add_to_group("player")  

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	var input_direction = Input.get_axis("ui_left", "ui_right")
	velocity.x = input_direction * spd

	if Input.is_action_just_pressed("ui_jump") and is_on_floor():
		velocity.y = jmp_forc

	move_and_slide()

func hurt(amount: int) -> void:
	hp -= amount
	print("HP:", hp)
	if hp <= 0:
		print("Player is dead!")
