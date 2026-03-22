extends Area2D

# Drag your Marker2D into this in the Inspector
@export var spawn_path: NodePath
@onready var spawn = get_node(spawn_path)

var player_in_range = false
var player = null

func _on_body_entered(body):
	print("entered:", body.name)
	if body.is_in_group("player"):
		print("PLAYER ENTERED")
		player_in_range = true
		player = body  # store the player reference

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		player = null  # clear player reference

func _process(delta):
	if player_in_range and player != null and Input.is_action_just_pressed("interact"):
		player.global_position = spawn.global_position
