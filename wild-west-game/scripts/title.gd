extends Node

func _on_ready() -> void:
	%MAIN.visible = true
	%CREDITS.visible = false

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_credits_pressed() -> void:
	%MAIN.visible = false
	%CREDITS.visible = true

func _on_back_pressed() -> void:
	%MAIN.visible = true
	%CREDITS.visible = false
