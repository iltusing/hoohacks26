extends CharacterBody2D

@export var speed: float = 100.0
@export var jump_velocity:= -300.0
@export var gravity:= 900.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

enum ActionState {
	NONE,
	SHOOTING,
	RELOADING,
}

var action_state: ActionState = ActionState.NONE

func _ready() -> void:
	animated_sprite_2d.sprite_frames.set_animation_loop("shoot", false)
	animated_sprite_2d.sprite_frames.set_animation_loop("reload", false)
	animated_sprite_2d.animation_finished.connect(_on_animation_finished)
	animated_sprite_2d.play("idle")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	var direction = Input.get_axis("move_left", "move_right")
	velocity.x = direction * speed

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	if Input.is_action_just_pressed("shoot") and action_state == ActionState.NONE:
		action_state = ActionState.SHOOTING
		animated_sprite_2d.play("shoot")


	move_and_slide()
	update_visuals()

func handle_jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

func handle_horizontal_movement():
	var direction = Input.get_axis("move_left", "move_right")
	velocity.x = direction * speed

func update_visuals():
	if velocity.x > 0:
		animated_sprite_2d.flip_h = false
	elif velocity.x < 0:
		animated_sprite_2d.flip_h = true
	
	if action_state != ActionState.NONE:
		return

	if not is_on_floor():
		if velocity.y < 0:
			animated_sprite_2d.play("jump")
		else:
			animated_sprite_2d.play("fall")
	elif abs(velocity.x) > 0:
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")

func _on_animation_finished() -> void:
	if animated_sprite_2d.animation == "shoot":
		action_state = ActionState.RELOADING
		animated_sprite_2d.play("reload")
	elif animated_sprite_2d.animation == "reload":
		action_state = ActionState.NONE
		update_visuals()
