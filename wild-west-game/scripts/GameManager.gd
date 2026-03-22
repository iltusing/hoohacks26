extends Node
var score: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	score = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func add_score(amount: int) -> void:
	score += amount
	print("Score: ", score)
