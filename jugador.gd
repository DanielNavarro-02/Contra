extends CharacterBody2D
# Solución del Taller 3 (solo profesor).

@export var speed = 60.0      # px/s
@export var gravedad = 980.0   # px/s²
@export var salto = 300.0      # px/s hacia arriba
@export var cadencia = 0.10   # segundos entre disparos

var mirando = 1                # 1 derecha, -1 izquierda
var espera = 0.0
var inicio = Vector2.ZERO
var muriendo = false

@onready var sprite = $AnimatedSprite2D
@onready var canon = $Canon    # por aquí salen las balas
@onready var sonido_disparo = $Disparo
@onready var sonido_muerte = $Muerte


func _ready():
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


func disparar():
	sonido_disparo.play()   # cada disparo es un sonido nuevo: aquí sí se reinicia


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
