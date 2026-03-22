extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var pickup_sound: AudioStreamPlayer = $AudioStreamPlayer

var unlocked: bool = false
var collected: bool = false

func _ready() -> void:
	add_to_group("quest_potions")
	set_unlocked(false)

func set_unlocked(state: bool) -> void:
	unlocked = state
	sprite_2d.visible = state
	collision_shape_2d.set_deferred("disabled", not state)

func _on_body_entered(body: Node2D) -> void:
	if collected:
		return
	
	if body.is_in_group("player") and unlocked:
		collected = true
		pickup_sound.play()
		sprite_2d.hide()
		collision_shape_2d.set_deferred("disabled", true)
		await pickup_sound.finished
		%BOTTLES.text = str(int(%BOTTLES.text) + 1)
		queue_free()
