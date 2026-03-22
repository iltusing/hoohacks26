extends Sprite2D

var original_x: float
var original_y: float

var shift_amount: float = 0.2

func _ready() -> void:
	original_x = self.position.x
	original_y = self.position.y

func _physics_process(_delta: float) -> void:
	self.position.x = randf_range(original_x-shift_amount,original_x+shift_amount)
	self.position.y = randf_range(original_y-shift_amount,original_y+shift_amount)
