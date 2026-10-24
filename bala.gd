extends Area2D

@export var speed: float = 100.0
var direction: float = 0.0
var disparador = null          # quién disparó la bala (jugador o soldado)

func _ready():
	rotation = direction
	# Desaparece sola a los 2 segundos si no choca
	await get_tree().create_timer(2.0).timeout
	queue_free()

func _physics_process(delta):
	# Mueve la bala en la dirección indicada
	position += Vector2(speed, 0).rotated(direction) * delta

func _on_body_entered(body):
	# No dañar a quien la disparó
	if body == disparador:
		return
	
	# Si el cuerpo tiene la función recibir_daño → le hace daño
	if body.has_method("recibir_daño"):
		body.recibir_daño(1)
	
	# La bala siempre desaparece al chocar
	queue_free()
