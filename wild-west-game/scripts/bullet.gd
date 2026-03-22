extends Node2D

@export var speed: float = 200.0

var direction: float = 1.0

func _process(delta: float) -> void:
	position.x += speed * direction * delta
