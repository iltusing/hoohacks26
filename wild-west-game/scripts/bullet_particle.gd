extends Node2D

@export var lifetime: float = 0.28
@export var fade_time: float = 0.28
@export var base_drift_speed: float = 24.0
@export var sideways_drift_speed: float = 18.0
@export var min_rotation_speed: float = -7.0
@export var max_rotation_speed: float = 7.0

@onready var particle: Sprite2D = $particle

var direction: float = 1.0
var _time_left: float
var _velocity: Vector2
var _rotation_speed: float

func _ready() -> void:
	_time_left = lifetime
	rotation = randf_range(0.0, TAU)
	_rotation_speed = randf_range(min_rotation_speed, max_rotation_speed)
	_velocity = Vector2(
		randf_range(-base_drift_speed, -base_drift_speed * 0.35) * direction,
		randf_range(-sideways_drift_speed, sideways_drift_speed)
	)

func _process(delta: float) -> void:
	position += _velocity * delta
	rotation += _rotation_speed * delta
	_time_left -= delta
	particle.modulate.a = clampf(_time_left / fade_time, 0.0, 1.0)

	if _time_left <= 0.0:
		queue_free()
