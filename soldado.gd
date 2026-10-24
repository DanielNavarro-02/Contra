extends CharacterBody2D

@export var speed = 120.0
@export var gravedad = 980.0
@export var cadencia = 1.2
@export var distancia_deteccion = 400.0
@export var distancia_disparo = 280.0
@export var vida_maxima = 5          # ← NUEVO

var mirando = 1
var espera = 0.0
var muriendo = false
var vida = 0
var bala = preload("res://bala.tscn")

@onready var sprite = $Sprite2D
@onready var canon = $Marker2D

var jugador: CharacterBody2D = null

func _ready():
	vida = vida_maxima
	jugador = get_tree().get_first_node_in_group("Bill")

func _physics_process(delta):
	if muriendo:
		return
	
	if not is_instance_valid(jugador):
		return
	
	mover(delta)
	orientar()
	
	espera -= delta
	
	var distancia = global_position.distance_to(jugador.global_position)
	if distancia <= distancia_disparo and espera <= 0.0:
		disparar()
		espera = cadencia

func mover(delta):
	if not is_on_floor():
		velocity.y += gravedad * delta
	else:
		velocity.y = 0
		
		if not is_instance_valid(jugador):
			velocity.x = 0
			move_and_slide()
			return
	
	var distancia = global_position.distance_to(jugador.global_position)
	var direccion = sign(jugador.global_position.x - global_position.x)
	
	if distancia > distancia_deteccion:
		velocity.x = 0
	elif distancia > distancia_disparo:
		# Se acerca
		velocity.x = direccion * speed
	else:
		# Distancia ideal → quieto
		velocity.x = 0
	
	move_and_slide()

func orientar():
	if is_instance_valid(jugador):
		var diferencia = jugador.global_position.x - global_position.x
		if abs(diferencia) > 5.0:
			mirando = sign(diferencia)
	
	sprite.flip_h = mirando > 0
	canon.position.x = abs(canon.position.x) * mirando

func disparar():
	if not is_instance_valid(jugador):
		return
	var newbala = bala.instantiate()
	
	var dir = (jugador.global_position - global_position).normalized()
	var angulo = dir.angle()
	var paso = PI / 4.0
	var angulo_8 = round(angulo / paso) * paso
	
	newbala.direction = angulo_8
	newbala.global_position = canon.global_position
	
	newbala.disparador = self
	
	get_parent().add_child(newbala)

# ——— NUEVO: recibir daño ———
func recibir_daño(cantidad: int = 1):
	if muriendo:
		return
	
	vida -= cantidad
	print("Jugador vida: ", vida)
	
	if vida <= 0:
		morir()

func morir():
	muriendo = true
	velocity = Vector2.ZERO
	# Aquí puedes poner una animación de muerte si quieres
	await get_tree().create_timer(0.4).timeout
	queue_free()
