extends Area2D
@export var valor = 200
@export var da_poder: bool = false
signal recogido(valor, da_poder)

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if body.is_in_group("Bill"):
		recogido.emit(valor, da_poder)
		queue_free()
