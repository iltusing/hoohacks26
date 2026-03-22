extends CharacterBody2D

@export var speed: float = 75.0
@export var jump_velocity:= -250.0
@export var gravity:= 900.0

var is_dead := false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ladder_ray_cast: RayCast2D = $ladderRayCast


func _physics_process(delta: float) -> void:
	if is_dead:
		return
	var ladderCollider = ladder_ray_cast.get_collider()
	
	if ladderCollider:
		_ladder_climb()
	else:
		_movement(delta)

	move_and_slide()

	
	
func _movement(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# gets input direction (0,-1,1)
	var direction := Input.get_axis("move_left", "move_right")
	
	# flips sprite
	if direction > 0:
		animated_sprite_2d.flip_h = false
	elif direction < 0:
		animated_sprite_2d.flip_h = true
	
	# play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite_2d.play("idle")
		else:
			animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("jump")
	
	
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()


func _ladder_climb():
	var direction = Vector2.ZERO
	
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("ui_up", "ui_down")
	
	if direction: 
		velocity = direction * speed / 2
		animated_sprite_2d.play("fall")
	else: 
		velocity = Vector2.ZERO
		animated_sprite_2d.stop()

func die():
	if is_dead:
		return
	
	is_dead = true
	
	velocity = Vector2.ZERO
	
	# Play death animation
	animated_sprite_2d.play("die")
