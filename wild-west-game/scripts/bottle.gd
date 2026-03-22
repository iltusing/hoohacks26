extends Area2D

@export var value: int = 1

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var collected: bool = false

func _on_body_entered(body: Node2D) -> void:
	if collected:
		return
	
	if body.is_in_group("player"):
		collected = true
		
		sprite_2d.hide()
		collision_shape_2d.set_deferred("disabled", true)
		%BOTTLES.text = str(int(%BOTTLES.text) + 1)
		queue_free()
