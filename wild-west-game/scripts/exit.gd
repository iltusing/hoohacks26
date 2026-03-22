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

func _unhandled_input(event):
	if player_in_range and event.is_action_pressed("interact"):
		get_tree().change_scene_to_file(target_scene)
