extends RigidBody2D

@export var walkspd := 60
@export var dmg := 0.1

var a_pos: Vector2
var b_pos: Vector2
var to_a := false

func _ready():
	a_pos = $PointA.global_position
	b_pos = $PointB.global_position

	
	$HitZone.body_entered.connect(_on_HitZone_body_entered)
	$HitZone.body_exited.connect(_on_HitZone_body_exited)

func _physics_process(delta: float) -> void:
	var target = a_pos if to_a else b_pos
	var dir = (target - global_position).normalized()
	linear_velocity = dir * walkspd

	
	if global_position.distance_to(target) < 5:
		to_a = !to_a
		$Sprite2D.flip_h = !to_a

func _on_HitZone_body_entered(body):
	if body.is_in_group("player"):
		body.start_damage()   

func _on_HitZone_body_exited(body):
	if body.is_in_group("player"):
		body.stop_damage()   
