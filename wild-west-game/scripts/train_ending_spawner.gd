extends Node

@export var total_enemies_to_spawn: int = 20
@export var start_spawn_interval: float = 5.0
@export var end_spawn_interval: float = 0.5
@export var spawn_height_above_player: float = 90.0
@export var min_side_offset: float = 28.0
@export var max_side_offset: float = 64.0

const ENEMY_SCENE := preload("res://scenes/enemy.tscn")

var _player: Node2D
var _spawned_enemies: int = 0
var _alive_enemies: int = 0
var _spawn_timer: Timer
var _spawn_left_next: bool = true
var _spawned_enemy_nodes: Array[PhysicsBody2D] = []

func _ready() -> void:
	randomize()
	_player = _resolve_player()
	if _player != null and not _player.is_in_group("player"):
		_player.add_to_group("player")

	_spawn_timer = Timer.new()
	_spawn_timer.wait_time = start_spawn_interval
	_spawn_timer.one_shot = true
	_spawn_timer.timeout.connect(_spawn_enemy)
	add_child(_spawn_timer)
	_spawn_timer.start()

func _spawn_enemy() -> void:
	if _player == null:
		_player = _resolve_player()
		if _player == null:
			return

	if _spawned_enemies >= total_enemies_to_spawn:
		_spawn_timer.stop()
		_try_finish()
		return

	var enemy := ENEMY_SCENE.instantiate()
	var side := -1.0 if _spawn_left_next else 1.0
	var x_offset := randf_range(min_side_offset, max_side_offset) * side

	_spawn_left_next = not _spawn_left_next
	enemy.global_position = _player.global_position + Vector2(x_offset, -spawn_height_above_player)
	enemy.died.connect(_on_enemy_died)
	_configure_spawned_enemy(enemy)
	get_tree().current_scene.add_child(enemy)

	_spawned_enemies += 1
	_alive_enemies += 1

	if _spawned_enemies >= total_enemies_to_spawn:
		_spawn_timer.stop()
	else:
		_spawn_timer.start(_get_next_spawn_interval())

func _on_enemy_died(_enemy: Node) -> void:
	_alive_enemies = max(_alive_enemies - 1, 0)
	_try_finish()

func _try_finish() -> void:
	if _spawned_enemies >= total_enemies_to_spawn and _alive_enemies == 0:
		get_tree().quit()

func _resolve_player() -> Node2D:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player != null:
		return player

	player = get_node_or_null("../Player") as Node2D
	if player != null:
		return player

	player = get_tree().current_scene.get_node_or_null("Player") as Node2D
	return player

func _configure_spawned_enemy(enemy: CharacterBody2D) -> void:
	enemy.add_to_group("train_ending_enemy")

	if _player is PhysicsBody2D:
		enemy.add_collision_exception_with(_player)

	for existing_enemy in _spawned_enemy_nodes:
		if is_instance_valid(existing_enemy):
			enemy.add_collision_exception_with(existing_enemy)
			existing_enemy.add_collision_exception_with(enemy)

	_spawned_enemy_nodes.append(enemy)

func _get_next_spawn_interval() -> float:
	if total_enemies_to_spawn <= 1:
		return end_spawn_interval

	var progress := float(_spawned_enemies) / float(total_enemies_to_spawn - 1)
	return lerpf(start_spawn_interval, end_spawn_interval, clampf(progress, 0.0, 1.0))
