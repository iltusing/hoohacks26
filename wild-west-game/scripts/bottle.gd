extends Area2D

@export var value: int = 1

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var pickup_sound: AudioStreamPlayer = $AudioStreamPlayer

var collected: bool = false

func _on_body_entered(body: Node2D) -> void:
	if collected:
		return
	
	if body.is_in_group("player"):
		collected = true
		pickup_sound.play()
		sprite_2d.hide()
		collision_shape_2d.set_deferred("disabled", true)
		await pickup_sound.finished
		%BOTTLES.text = str(int(%BOTTLES.text) + 1)
		queue_free()
