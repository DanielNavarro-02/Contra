extends CharacterBody2D
# Solución del Taller 3 (solo profesor).

@export var vida_maxima = 5
@export var speed = 180.0      # px/s
@export var gravedad = 980.0   # px/s²
@export var salto = 400.0      # px/s hacia arriba
@export var cadencia = 0.15    # segundos entre disparos

var mirando = 1                # 1 derecha, -1 izquierda
var espera = 0.0
var inicio = Vector2.ZERO
var muriendo = false
var bala = preload("res://bala.tscn")
var vida = 0

@onready var sprite = $AnimatedSprite2D
@onready var canon = $Canon    # por aquí salen las balas
@onready var sonido_disparo = $Disparo
@onready var sonido_muerte = $Muerte


func _ready():
	vida = vida_maxima
	inicio = position


func _physics_process(delta):
	if muriendo:
		return
	if Input.is_action_just_pressed("morir"):
		morir()
		return
	mover(delta)
	actualizar_animacion()
	orientar()
	espera -= delta
	if Input.is_action_pressed("disparar") and espera <= 0.0:
		disparar()
		espera = cadencia


func mover(delta):
	if not is_on_floor():
		velocity.y += gravedad * delta
	if Input.is_action_just_pressed("saltar") and is_on_floor():
		velocity.y = -salto
	velocity.x = Input.get_axis("move_left", "move_right") * speed
	move_and_slide()


# Nivel 1 (y nivel 3: speed_scale)
func actualizar_animacion():
	var real = get_real_velocity()
	if not is_on_floor():
		sprite.play("saltar")
		sprite.speed_scale = 1.0
	elif abs(real.x) > 1.0:
		sprite.play("correr")
		sprite.speed_scale = abs(real.x) / speed
	else:
		sprite.play("quieto")
		sprite.speed_scale = 1.0


# Nivel 2
func orientar():
	var eje = Input.get_axis("move_left", "move_right")
	if eje != 0:
		mirando = sign(eje)
	sprite.flip_h = mirando < 0
	canon.position.x = 28 * mirando   # flip_h no mueve a los hijos: el cañón hay que moverlo

func obtener_direccion_disparo() -> float:
	var dir = Vector2.ZERO
	
	# Horizontal
	dir.x = Input.get_axis("move_left", "move_right")
	
	# Vertical (tus nuevas acciones)
	if Input.is_action_pressed("Apuntar_Arriba"):
		dir.y = -1
	elif Input.is_action_pressed("Apuntar_Abajo"):
		dir.y = 1
	
	# Si no hay input de dirección, dispara hacia donde mira
	if dir == Vector2.ZERO:
		dir.x = mirando
	
	# Normalizamos y convertimos a ángulo
	dir = dir.normalized()
	return dir.angle()

func disparar():
	var newbala = bala.instantiate()
	
	# Ángulo en 8 direcciones (o libre según el input)
	newbala.direction = obtener_direccion_disparo()
	newbala.global_position = $Canon.global_position
	newbala.disparador = self
	
	get_parent().add_child(newbala)
	sonido_disparo.play()

func recibir_daño(cantidad: int = 1):
	if muriendo:
		return
		
	vida -= cantidad
	print("Jugador vida: ", vida)
	
	if vida <= 0:
		morir()

# Nivel 3
func morir():
	muriendo = true
	velocity = Vector2.ZERO
	sprite.speed_scale = 1.0
	sprite.play("morir")
	sonido_muerte.play()
	await sprite.animation_finished
	position = inicio
	sprite.play("quieto")
	muriendo = false
