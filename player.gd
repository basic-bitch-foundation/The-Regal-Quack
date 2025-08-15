extends CharacterBody2D

@export var spd := 400       
@export var jmp_forrc := -300  
@export var gravity := 600   

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0  

	
	var input_direction = Input.get_axis("ui_left", "ui_right")
	velocity.x = input_direction * spd

	
	if Input.is_action_just_pressed("ui_jump") and is_on_floor():
		velocity.y = jmp_forrc

	
	move_and_slide()
