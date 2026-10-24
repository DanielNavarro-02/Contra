extends CharacterBody2D
# Solución del Taller 3 (solo profesor).

@export var vida_maxima = 5
@export var speed = 180.0      # px/s
@export var gravedad = 980.0   # px/s²
@export var salto = 400.0      # px/s hacia arriba
@export var cadencia = 0.15    # segundos entre disparos

var mirando = 1                # 1 derecha, -1 izquierda
var espera = 1.0
var inicio = Vector2.ZERO
var muriendo = false
var bala = preload("res://bala.tscn")
var vida = 0
var agachado = false
var atravesando = false

@onready var sprite = $AnimatedSprite2D
@onready var canon = $Canon    # por aquí salen las balas
@onready var sonido_disparo = $Disparo
@onready var sonido_muerte = $Muerte
@onready var colision = $CollisionShape2D


func _ready():
	vida = vida_maxima
	inicio = position


func _physics_process(delta):
	if muriendo:
		return
		
	if Input.is_action_just_pressed("morir"):
		morir()
		return
		
	manejar_agachado()
	mover(delta)
	actualizar_animacion()
	orientar()
	
	espera -= delta
	if Input.is_action_pressed("disparar") and espera <= 0.0:
		disparar()
		espera = cadencia
		
func manejar_agachado():
	agachado = Input.is_action_pressed("Apuntar_Abajo") and is_on_floor() and not atravesando
	
	if agachado and Input.is_action_just_pressed("saltar"):
		atravesar_suelo()
		
func atravesar_suelo():
	if atravesando:
		return
		
	atravesando = true
	velocity.y = 100
		
	set_collision_mask_value(1, false)
		
	print("Mascara actual: ", collision_mask)
		
	await get_tree().create_timer(0.1).timeout
		
	set_collision_mask_value(1, true)
	atravesando = false
		
	print("Mascara restaurada: ", collision_mask)
		

func mover(delta):
	if not is_on_floor():
		velocity.y += gravedad * delta
		
	if Input.is_action_just_pressed("saltar") and is_on_floor() and not agachado and not atravesando:
		velocity.y = -salto
		
	var velocidad_actual = speed * 0.5 if agachado else speed
	velocity.x = Input.get_axis("move_left", "move_right") * velocidad_actual
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
	
	var pos_x = 28 * mirando
	var pos_y = 0.0
	
	if Input.is_action_pressed("Apuntar_Arriba"):
		pos_y = -20
	elif Input.is_action_pressed("Apuntar_Abajo"):
		pos_y = 20 
	
	canon.position = Vector2(pos_x, pos_y)   # flip_h no mueve a los hijos: el cañón hay que moverlo
	

func obtener_direccion_disparo() -> float:
	var dir = Vector2.ZERO
	
	# Horizontal
	dir.x = Input.get_axis("move_left", "move_right")
	
	# Vertical (tus nuevas acciones)
	if Input.is_action_pressed("Apuntar_Arriba"):
		dir.y = -1
	if Input.is_action_pressed("Apuntar_Abajo"):
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
