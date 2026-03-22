extends CanvasGroup

@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var coin_sound: AudioStreamPlayer = $AudioStreamPlayer


var quest_started: bool = false
var quest_completed: bool = false

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	
	var bottles_label = get_tree().current_scene.get_node("%BOTTLES")
	var coins_label = get_tree().current_scene.get_node("%COINS")
	var bottles_ui = get_tree().current_scene.get_node("%HBOX_BOTTLES")
	
	var bottle_count = int(bottles_label.text)

	if not quest_started:
		quest_started = true
		rich_text_label.text = "Hey, bring me 10 bottles of Cowboy Juice!"
		rich_text_label.visible = true
		bottles_ui.visible = true
		
		for potion in get_tree().get_nodes_in_group("quest_potions"):
			potion.set_unlocked(true)

	elif not quest_completed and bottle_count >= 10:
		quest_completed = true
		rich_text_label.text = "Much obliged! Here's your pay."
		rich_text_label.visible = true
		
		bottles_ui.visible = false
		bottles_label.text = "0"
		
		coin_sound.play()
		coins_label.text = str(int(coins_label.text) + 4)
		if int(coins_label.text) >= 20:
			get_tree().change_scene_to_file("res://scenes/train_ending.tscn")

	elif not quest_completed: 
		rich_text_label.text = "I'm still waitin' on those 10 bottles."
		rich_text_label.visible = true

	else:
		rich_text_label.text = "Pleasure doin' business with ya."
		rich_text_label.visible = true
