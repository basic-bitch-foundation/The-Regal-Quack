extends CharacterBody2D

@export var spd: float = 400
@export var jmp_forc: float = -300
@export var gravity: float = 600
@export var maxhp: int = 10
@export var drain_rate: float = 0.005  

var hp: int
var bg_hp: float
var touching_enemy: bool = false

func _ready() -> void:
	add_to_group("player")
	hp = maxhp
	bg_hp = float(maxhp)

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# Movement
	var input_direction = Input.get_axis("ui_left", "ui_right")
	velocity.x = input_direction * spd

	if Input.is_action_just_pressed("ui_jump") and is_on_floor():
		velocity.y = jmp_forc

	move_and_slide()

	
	if touching_enemy:
		bg_hp -= drain_rate * (delta * 1000.0)  # convert sec -> ms
		bg_hp = max(bg_hp, 0.0)


		var new_hp: int = int(floor(bg_hp))
		if new_hp != hp:
			hp = new_hp
			print("HP decreased to:", hp)

	
	print("HP:", hp, " | BG_HP:", bg_hp)

func hurt(amount: int) -> void:
	bg_hp -= amount
	bg_hp = max(bg_hp, 0.0)
	hp = int(floor(bg_hp))
	print("HP:", hp, " | BG_HP:", bg_hp)
	if hp <= 0:
		print("Player is dead!")


func start_damage() -> void:
	touching_enemy = true

func stop_damage() -> void:
	touching_enemy = false
