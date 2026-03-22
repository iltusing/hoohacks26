extends Node2D

@export var speed: float = 200.0
@export var trail_spawn_interval: float = 0.05
@export var trail_side_offset: float = 1.0
@export var trail_back_offset: float = 3.0

const BULLET_PARTICLE_SCENE := preload("res://scenes/bullet-particle.tscn")

var direction: float = 1.0
var _trail_timer: float = 0.0

func _process(delta: float) -> void:
	position.x += speed * direction * delta
	_trail_timer -= delta

	if _trail_timer <= 0.0:
		_spawn_trail_particle()
		_trail_timer = trail_spawn_interval

func _spawn_trail_particle() -> void:
	var particle := BULLET_PARTICLE_SCENE.instantiate()
	var side_offset := randf_range(-trail_side_offset, trail_side_offset)
	var particle_position := global_position + Vector2(-trail_back_offset * direction, side_offset)

	particle.global_position = particle_position
	particle.direction = direction
	get_tree().current_scene.add_child(particle)
