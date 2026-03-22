extends Area2D

@export var speed: float = 200.0
@export var trail_spawn_interval: float = 0.05
@export var trail_side_offset: float = 1.0
@export var trail_back_offset: float = 3.0
@export var lifetime: float = 2.0
@export var damage: int = 20

const BULLET_PARTICLE_SCENE := preload("res://scenes/bullet-particle.tscn")

var direction: float = 1.0
var owner_type: String = ""
var shooter: Node = null
var _trail_timer: float = 0.0
var _time_left: float = lifetime

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_time_left = lifetime

func _process(delta: float) -> void:
	position.x += speed * direction * delta
	_trail_timer -= delta
	_time_left -= delta

	if _trail_timer <= 0.0:
		_spawn_trail_particle()
		_trail_timer = trail_spawn_interval

	if _time_left <= 0.0:
		queue_free()

func _spawn_trail_particle() -> void:
	var particle := BULLET_PARTICLE_SCENE.instantiate()
	var side_offset := randf_range(-trail_side_offset, trail_side_offset)
	var particle_position := global_position + Vector2(-trail_back_offset * direction, side_offset)

	particle.global_position = particle_position
	particle.direction = direction
	get_tree().current_scene.add_child(particle)

func _on_body_entered(body: Node) -> void:
	if body == shooter:
		return

	if owner_type == "enemy" and body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
		return

	if owner_type == "player" and body.has_method("die") and not body.is_in_group("player"):
		body.die()
		queue_free()
		return

	if body != self:
		queue_free()
