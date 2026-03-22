extends CharacterBody2D

@export var speed: float = 75.0
@export var jump_velocity:= -250.0
@export var gravity:= 900.0

const BULLET_SCENE := preload("res://scenes/bullet.tscn")
const BULLET_SPAWN_OFFSET := Vector2(0.0, 2.0)
const MAX_HEALTH := 100
var is_dead := false
var is_climbing_ladder := false
var health := MAX_HEALTH
var coins: int = 0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ladder_ray_cast: RayCast2D = $ladderRayCast


enum ActionState {
	NONE,
	SHOOTING,
	RELOADING,
}

var action_state: ActionState = ActionState.NONE

func _ready() -> void:
	%GAMEOVER.visible = false
	animated_sprite_2d.sprite_frames.set_animation_loop("shoot", false)
	animated_sprite_2d.sprite_frames.set_animation_loop("reload", false)
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)
	animated_sprite_2d.play("idle")
	_update_health_label()
	_update_coins_label()

func _physics_process(delta: float) -> void:
	if is_dead:
		move_and_slide()
		return

	var on_ladder := ladder_ray_cast.get_collider() != null
	var climb_input := _get_ladder_input()

	if on_ladder and climb_input != 0.0:
		is_climbing_ladder = true
	elif not on_ladder:
		is_climbing_ladder = false

	if is_climbing_ladder:
		velocity.y = 0.0
	elif not is_on_floor():
		velocity.y += gravity * delta

	var direction = Input.get_axis("move_left", "move_right")

	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_climbing_ladder:
		velocity.y = jump_velocity
	
	if Input.is_action_just_pressed("shoot") and action_state == ActionState.NONE:
		action_state = ActionState.SHOOTING
		spawn_bullet()
		animated_sprite_2d.play("shoot")

	if is_climbing_ladder:
		_ladder_climb(direction, climb_input, on_ladder)
	else:
		_movement(direction)

	move_and_slide()

	
func _movement(direction: float) -> void:
	animated_sprite_2d.speed_scale = 1.0

	if direction > 0:
		animated_sprite_2d.flip_h = false
	elif direction < 0:
		animated_sprite_2d.flip_h = true

	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	if action_state != ActionState.NONE:
		return

	if not is_on_floor():
		if velocity.y < 0:
			animated_sprite_2d.play("jump")
		else:
			animated_sprite_2d.play("fall")
	elif direction == 0:
		animated_sprite_2d.play("idle")
	else:
		animated_sprite_2d.play("run")

func _on_animation_finished() -> void:
	if animated_sprite_2d.animation == "shoot":
		action_state = ActionState.RELOADING
		animated_sprite_2d.play("reload")
	elif animated_sprite_2d.animation == "reload":
		action_state = ActionState.NONE
		if is_climbing_ladder:
			_update_ladder_animation(Vector2.ZERO)
		else:
			_movement(Input.get_axis("move_left", "move_right"))

func spawn_bullet() -> void:
	var bullet := BULLET_SCENE.instantiate()
	var bullet_direction := -1.0 if animated_sprite_2d.flip_h else 1.0

	bullet.direction = bullet_direction
	bullet.owner_type = "player"
	bullet.shooter = self
	bullet.global_position = global_position + Vector2(BULLET_SPAWN_OFFSET.x * bullet_direction, BULLET_SPAWN_OFFSET.y)
	bullet.scale.x = absf(bullet.scale.x) * bullet_direction
	get_tree().current_scene.add_child(bullet)
	
func _ladder_climb(horizontal_input: float, climb_input: float, on_ladder: bool) -> void:
	var direction := Vector2(horizontal_input, climb_input)
	
	if direction.x > 0:
		animated_sprite_2d.flip_h = false
	elif direction.x < 0:
		animated_sprite_2d.flip_h = true

	if not on_ladder:
		is_climbing_ladder = false
		return

	if direction != Vector2.ZERO:
		velocity = direction * speed / 2.0
	else:
		velocity = Vector2.ZERO

	_update_ladder_animation(direction)

func _get_ladder_input() -> float:
	var climb_up := Input.get_action_strength("jump")
	var climb_down := Input.get_action_strength("down")

	return climb_down - climb_up

func _update_ladder_animation(direction: Vector2) -> void:
	if action_state != ActionState.NONE:
		return

	if direction == Vector2.ZERO:
		if animated_sprite_2d.animation != "climb":
			animated_sprite_2d.play("climb")
		animated_sprite_2d.speed_scale = 0.0
	else:
		animated_sprite_2d.speed_scale = 1.0
		animated_sprite_2d.play("climb")

func die():
	if is_dead:
		return
	
	%GAMEOVER.visible = true
	is_dead = true
	
	velocity = Vector2.ZERO
	
	# Play death animation
	animated_sprite_2d.play("die")
	_return_to_title()

func take_damage(amount: int) -> void:
	if is_dead:
		return

	health = max(health - amount, 0)
	_update_health_label()

	if health == 0:
		die()

func add_coins(amount: int) -> void:
	coins += amount
	_update_coins_label()

func _update_health_label() -> void:
	var health_label := find_child("HEALTH", true, false) as Label

	if health_label:
		health_label.text = str(health)

func _update_coins_label() -> void:
	var coins_label := find_child("COINS", true, false) as Label

	if coins_label:
		coins_label.text = str(coins)

func _return_to_title() -> void:
	Engine.time_scale = 0.5
	await get_tree().create_timer(4.0, true, false, true).timeout
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://scenes/title.tscn")
