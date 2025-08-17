extends CharacterBody2D
@export var spd: float = 400
@export var jmp_forc: float = -300
@export var gravity: float = 600
@export var maxhp: int = 10
@export var drain_rate: float = 0.005 
var hp: int
var bg_hp: float
var touching_enemy: bool = false

var collectible_layer: TileMapLayer = null
var debug_printed: bool = false

var raycast: RayCast2D

func _ready() -> void:
	add_to_group("player")
	hp = maxhp
	bg_hp = float(maxhp)
	
	raycast = RayCast2D.new()
	add_child(raycast)
	raycast.enabled = true
	raycast.target_position = Vector2(0, 50)
	raycast.collision_mask = 1
	
	print("\nronaldo debug")
	_find_layer_aggressively()

func _find_layer_aggressively() -> void:
	print("=== SCENE STRUCTURE ===")
	var scene_root = get_tree().current_scene
	print("Scene root: ", scene_root.name)
	
	
	_print_all_nodes(scene_root, 0)
	
	
	var attempts = [
		{"method": "Direct path 1", "code": "get_tree().get_current_scene().get_node('TileMap2/Layer1')"},
		{"method": "Direct path 2", "code": "get_node('../TileMap2/Layer1')"},
		{"method": "Find child", "code": "get_tree().current_scene.find_child('Layer1', true, false)"},
		{"method": "Parent search", "code": "get_parent().get_node('TileMap2/Layer1')"}
	]
	
	for attempt in attempts:
		print("\ntry ", attempt.method,)
		match attempt.method:
			"Direct path 1":
				collectible_layer = get_tree().get_current_scene().get_node_or_null("TileMap2/Layer1")
			"Direct path 2":
				collectible_layer = get_node_or_null("../TileMap2/Layer1")
			"Find child":
				collectible_layer = get_tree().current_scene.find_child("Layer2", true, false)
			"Parent search":
				collectible_layer = get_parent().get_node_or_null("TileMap2/Layer1")
		
		if collectible_layer:
			print("lyr 2 fnd ", attempt.method)
			print("Path: ", collectible_layer.get_path())
			break
		else:
			print("faild: ", attempt.method)
	
	if collectible_layer:
		_test_layer_thoroughly()
	else:
		print("\n nope layer")

func _print_all_nodes(node: Node, depth: int) -> void:
	var indent = ""
	for i in range(depth):
		indent += "  "
	
	var node_class = node.get_class()
	print(indent + "- " + node.name + " (" + node_class + ")")
	
	
	if node_class.contains("TileMap"):
		print(indent + "  tilemp fnd")
	if node.name == "Layer2":
		print(indent + "  lyr fnd 2")
	
	for child in node.get_children():
		_print_all_nodes(child, depth + 1)

func _test_layer_thoroughly() -> void:
	print("\nlyr 2 coord")
	print("Layer2 class: ", collectible_layer.get_class())
	print("Layer2 path: ", collectible_layer.get_path())
	
	
	print("\ntilecoord")
	var found_any_tiles = false
	for x in range(-10, 11):
		for y in range(-10, 11):
			var test_coord = Vector2i(x, y)
			var source_id = collectible_layer.get_cell_source_id(test_coord)
			if source_id != -1:
				found_any_tiles = true
				var tile_data = collectible_layer.get_cell_tile_data(test_coord)
				print("Tile at (" + str(x) + "," + str(y) + ") - source_id:" + str(source_id))
				
				if tile_data:
					print("  Custom data layer count: " + str(tile_data.get_custom_data_layer_count()))
					if tile_data.has_custom_data("type"):
						var type_val = tile_data.get_custom_data("type")
						print("  Type: '" + str(type_val) + "'")
						if type_val == "chickleg":
							print("atlast found")
	
	if not found_any_tiles:
		print("no lyr2 tiles")
		

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
	
	_check_raycast_collectibles()
	
	if touching_enemy:
		bg_hp -= drain_rate * (delta * 1000.0)
		bg_hp = max(bg_hp, 0.0)
		var new_hp: int = int(floor(bg_hp))
		if new_hp != hp:
			hp = new_hp
			print("hp minus", hp)
	
	
	if collectible_layer:
		_check_collectibles_max_debug()
	
	
	if not debug_printed and Engine.get_process_frames() > 60:
		debug_printed = true
		print("\nplayer pos.")
		print("Player global position: " + str(global_position))
		if collectible_layer:
			var player_tile = collectible_layer.local_to_map(collectible_layer.to_local(global_position))
			print("Player tile coordinate: " + str(player_tile))
	
	
	if Engine.get_process_frames() % 60 == 0:
		print("HP:", hp, " | BG_HP:", bg_hp)

func _check_raycast_collectibles() -> void:
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		var collision_point = raycast.get_collision_point()
		
		print("🔍 RAYCAST HIT:")
		print("  Collider: ", collider)
		print("  Collision point: ", collision_point)
		print("  Collider class: ", collider.get_class() if collider else "None")
		
		if collider and collider.get_class().contains("TileMap"):
			var tilemap = collider as TileMap
			var local_pos = tilemap.to_local(collision_point)
			var tile_pos = tilemap.local_to_map(local_pos)
			
			print("  TileMap hit at tile position: ", tile_pos)
			
			for i in range(tilemap.get_layers_count()):
				var layer = tilemap.get_layer(i)
				if layer:
					var source_id = layer.get_cell_source_id(tile_pos)
					if source_id != -1:
						var tile_data = layer.get_cell_tile_data(tile_pos)
						if tile_data and tile_data.has_custom_data("type"):
							var tile_type = tile_data.get_custom_data("type")
							print("raycst leg fnd :")
							print("    Layer: ", i)
							print("    Type: '", tile_type, "'")
							print("    Tile position: ", tile_pos)
							if tile_type == "chickleg":
								print("    Chicken lg fnd")

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

func _check_collectibles_max_debug() -> void:
	var player_tile = collectible_layer.local_to_map(collectible_layer.to_local(global_position))
	
	
	for x in range(-2, 3):
		for y in range(-2, 3):
			var check_tile = player_tile + Vector2i(x, y)
			var source_id = collectible_layer.get_cell_source_id(check_tile)
			
			if source_id != -1:
				print(" Found tile at ", check_tile, " (offset ", x, ",", y, ") - source_id: ", source_id)
				var tile_data = collectible_layer.get_cell_tile_data(check_tile)
				
				if tile_data:
					if tile_data.has_custom_data("type"):
						var tile_type = tile_data.get_custom_data("type")
						print("   Type: '", tile_type, "'")
						
						if tile_type == "chickleg":
							print("chickleg")
							bg_hp = min(bg_hp + 0.5, maxhp)
							hp = int(floor(bg_hp))
							print("   HP now: ", hp)
							collectible_layer.set_cell(check_tile, -1)
							return
					else:
						print("     custom data")
				else:
					print("tile datanotfnd")
