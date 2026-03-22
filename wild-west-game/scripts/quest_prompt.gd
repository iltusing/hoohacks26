extends CanvasGroup
@onready var rich_text_label: RichTextLabel = $RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		rich_text_label.visible = true
		get_tree().current_scene.get_node("%HBOX_BOTTLES").visible = true
