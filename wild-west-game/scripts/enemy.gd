extends CharacterBody2D

@export var walk_speed: float = 37.5
@export var chase_speed: float = 37.5
@export var jump_velocity: float = -220.0
@export var gravity: float = 900.0
@export var aggro_distance: float = 75.0
@export var shoot_interval: float = 1.4
@export var wander_interval_min: float = 0.8
@export var wander_interval_max: float = 2.2
@export var jump_height_threshold: float = 12.0
@export var stop_distance: float = 18.0

const BULLET_SCENE := preload("res://scenes/bullet.tscn")
const COIN_SCENE := preload("res://scenes/coin.tscn")
const BULLET_SPAWN_OFFSET := Vector2(10.0, 1.0)

enum ActionState {
	NONE,
	ATTACKING,
	RELOADING,
	DYING,
}

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var left_ground_check: RayCast2D = $LeftGroundCheck
@onready var right_ground_check: RayCast2D = $RightGroundCheck
@onready var die2: AudioStreamPlayer = $AudioStreamPlayer
@onready var shoot_sound: AudioStreamPlayer = $AudioStreamPlayer2



var player: CharacterBody2D
var action_state: ActionState = ActionState.NONE
var wander_direction: float = 0.0
var wander_timer: float = 0.0
var shoot_timer: float = 0.0
var is_dead: bool = false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	animated_sprite_2d.sprite_frames.set_animation_loop("attack", false)
	animated_sprite_2d.sprite_frames.set_animation_loop("reload", false)
	animated_sprite_2d.sprite_frames.set_animation_loop("die", false)
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)
	_pick_new_wander_direction()
	animated_sprite_2d.play("walk")

func _physics_process(delta: float) -> void:
	if is_dead:
		move_and_slide()
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	shoot_timer = max(shoot_timer - delta, 0.0)

	var is_aggro := _is_player_in_aggro_range()
	if is_aggro:
		_handle_aggro(delta)
	else:
		_handle_wander(delta)

	move_and_slide()

func _handle_wander(delta: float) -> void:
	wander_timer -= delta
	if wander_timer <= 0.0:
		_pick_new_wander_direction()

	if _will_walk_off_edge():
		wander_direction *= -1.0
		wander_timer = randf_range(wander_interval_min, wander_interval_max)

	velocity.x = wander_direction * walk_speed
	_update_facing()

	if action_state == ActionState.NONE:
		if is_zero_approx(wander_direction):
			animated_sprite_2d.stop()
		else:
			animated_sprite_2d.play("walk")

func _handle_aggro(_delta: float) -> void:
	if player == null:
		velocity.x = 0.0
		return

	var x_distance_to_player: float = player.global_position.x - global_position.x
	var direction_to_player: float = sign(x_distance_to_player)
	if is_zero_approx(direction_to_player):
		direction_to_player = 1.0

	if absf(x_distance_to_player) <= stop_distance:
		velocity.x = 0.0
	else:
		velocity.x = direction_to_player * chase_speed

	_update_facing(direction_to_player)

	if is_on_floor() and player.global_position.y < global_position.y - jump_height_threshold:
		velocity.y = jump_velocity

	if shoot_timer <= 0.0 and action_state == ActionState.NONE:
		_fire_at_player()

	if action_state == ActionState.NONE:
		animated_sprite_2d.play("walk")

func _is_player_in_aggro_range() -> bool:
	if player == null or is_dead:
		return false

	return global_position.distance_to(player.global_position) <= aggro_distance

func _pick_new_wander_direction() -> void:
	var directions := [-1.0, 0.0, 1.0]
	wander_direction = directions[randi() % directions.size()]
	wander_timer = randf_range(wander_interval_min, wander_interval_max)

func _will_walk_off_edge() -> bool:
	if not is_on_floor():
		return false

	if wander_direction < 0.0:
		return not left_ground_check.is_colliding()
	if wander_direction > 0.0:
		return not right_ground_check.is_colliding()

	return false

func _fire_at_player() -> void:
	action_state = ActionState.ATTACKING
	shoot_timer = shoot_interval
	_spawn_bullet()
	shoot_sound.play()
	animated_sprite_2d.play("attack")

func _spawn_bullet() -> void:
	var bullet := BULLET_SCENE.instantiate()
	var bullet_direction := -1.0 if animated_sprite_2d.flip_h else 1.0

	bullet.direction = bullet_direction
	bullet.owner_type = "enemy"
	bullet.shooter = self
	bullet.global_position = global_position + Vector2(BULLET_SPAWN_OFFSET.x * bullet_direction, BULLET_SPAWN_OFFSET.y)
	bullet.scale.x = absf(bullet.scale.x) * bullet_direction
	get_tree().current_scene.add_child(bullet)

func _update_facing(direction_hint: float = 0.0) -> void:
	if direction_hint > 0.0:
		animated_sprite_2d.flip_h = false
	elif direction_hint < 0.0:
		animated_sprite_2d.flip_h = true
	elif velocity.x > 0:
		animated_sprite_2d.flip_h = false
	elif velocity.x < 0:
		animated_sprite_2d.flip_h = true

func _on_animation_finished() -> void:
	if animated_sprite_2d.animation == "attack" and action_state == ActionState.ATTACKING:
		action_state = ActionState.RELOADING
		animated_sprite_2d.play("reload")
	elif animated_sprite_2d.animation == "reload" and action_state == ActionState.RELOADING:
		action_state = ActionState.NONE
	elif animated_sprite_2d.animation == "die" and action_state == ActionState.DYING:
		_drop_coin()
		queue_free()

func die() -> void:
	if is_dead:
		return
	
	is_dead = true
	action_state = ActionState.DYING
	die2.play()
	velocity = Vector2.ZERO
	collision_shape_2d.set_deferred("disabled", true)
	animated_sprite_2d.play("die")

func _drop_coin() -> void:
	var coin := COIN_SCENE.instantiate()
	coin.global_position = global_position
	get_tree().current_scene.add_child(coin)


func _on_killzone_body_entered(body: Node2D) -> void:
	if body == self:
		die()
