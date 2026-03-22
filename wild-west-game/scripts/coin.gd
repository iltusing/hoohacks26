extends Area2D

@export var value: int = 1

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var pickup_sound: AudioStreamPlayer = $AudioStreamPlayer

var collected: bool = false

func _on_body_entered(body: Node2D) -> void:
	if collected:
		return
	
	if body.is_in_group("player"):
		collected = true
		
		animated_sprite_2d.hide()
		collision_shape_2d.set_deferred("disabled", true)
		%COINS.text = str(int(%COINS.text) + 1)
		pickup_sound.play()
		await pickup_sound.finished
		queue_free()
