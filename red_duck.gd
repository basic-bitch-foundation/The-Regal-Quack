extends CharacterBody2D

@export var walkspd := 60
@export var dmg := 1
@export var hurt_delay := 0.05

var a_pos: Vector2
var b_pos: Vector2
var to_a := false
var can_hurt := true

func _ready():
	a_pos = $PointA.global_position
	b_pos = $PointB.global_position
	
	
	$HitZone.body_entered.connect(_on_HitZone_body_entered)

func _physics_process(delta: float) -> void:
	var target = a_pos if to_a else b_pos
	var dir = (target - global_position).normalized()
	velocity.x = dir.x * walkspd
	move_and_slide()

	if global_position.distance_to(target) < 5:
		to_a = !to_a
		$Sprite2D.flip_h = !to_a

func _on_HitZone_body_entered(body):
	if body.is_in_group("player") and can_hurt:
		body.hurt(dmg)
		can_hurt = false
		get_tree().create_timer(hurt_delay).timeout.connect(func():
			can_hurt = true)
