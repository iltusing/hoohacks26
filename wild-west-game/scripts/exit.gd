extends Area2D

@export var target_scene: String = "res://scenes/main.tscn"

var player_in_range = false

func _on_body_entered(body):
	print("entered:", body.name)
	if body.is_in_group("player"):
		print("PLAYER ENTERED")
		player_in_range = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false

func _process(delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		get_tree().change_scene_to_file(target_scene)
