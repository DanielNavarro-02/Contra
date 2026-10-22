extends Area2D

@export var speed: float = 1000.0
var direction: float = 0.0

func _ready():
	rotation = direction
	# Desaparece automáticamente a los 2 segundos si no choca
	await get_tree().create_timer(2.0).timeout
	queue_free()

func _physics_process(delta):
	position += Vector2(speed, 0).rotated(direction) * delta

func _on_body_entered(body):
	# Si choca con algo que tenga la función recibir_daño
	if body.has_method("recibir_daño"):
		body.recibir_daño(1)   # quita 1 de vida
	
	queue_free()   # la bala siempre desaparece al chocar
