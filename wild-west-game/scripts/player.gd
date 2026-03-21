extends CharacterBody2D

@export var speed: float = 70.0
@export var jump_velocity:= -350.0
@export var gravity:= 900.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_jump()
	handle_horizontal_movement()
	move_and_slide()
	update_visuals()

func handle_jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

func handle_horizontal_movement():
	var direction = Input.get_axis("move_left", "move_right")
	velocity.x = direction * speed

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func update_visuals():
	pass
