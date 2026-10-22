extends "res://bloques.gd"

var puntaje = 0
var modo_poder = false
# Base del Taller 4. construir() arma el nivel a partir del MAPA:
# "#" bloque, "." medalla, "o" barrera, "E" soldado.

const MAPA = [
	".           .",
	"    .     E .   o E",
	"  o              ",
	"     .         . ",
	"        .        ",
	"                 ",
]

var medalla_escena = preload("res://medalla.tscn")
var barrera_escena = preload("res://barrera.tscn")
var soldado_escena = preload("res://soldado.tscn")


func _ready():
	construir()
	# Buscamos los nodos en el grupo "medallas"
	for item in get_tree().get_nodes_in_group("medallas"): 
		# Conectamos la señal de cada medalla a la función local
		item.recogido.connect(_on_recogido)


func construir():
	# COMENTADO O ELIMINADO: Ya no generamos bloques por código
	# construir_bloques(MAPA, Color(0.45, 0.35, 0.2, 1))
	
	for fila in MAPA.size():
		for col in MAPA[fila].length():
			var escena = null
			match MAPA[fila][col]:
				".":
					escena = medalla_escena
				"o":
					escena = barrera_escena
				"E":
					escena = soldado_escena
			
			if escena:
				var nodo = escena.instantiate()
				# Mantenemos el cálculo de posición original basado en el tamaño de tu CELDA (16x16)
				nodo.position = Vector2(col + 0.5, fila + 0.5) * CELDA
				
				# ¡IMPORTANTE!: Asegúrate de que este nodo de destino sea tu nuevo TileMapLayer o un Node2D simple
				$mapa.add_child(nodo)

				
func _on_recogido(valor, da_poder):
	# Sumamos el valor de la medalla recogida al puntaje actual
	puntaje += valor 
	$HUD/Puntaje.text = "Puntaje: %d" % puntaje
	
	if da_poder:
		activar_poder()
		
	# Comprobamos si la cantidad de nodos en el grupo es igual a 1 
	# (la medalla actual que se está terminando de procesar)
	if get_tree().get_nodes_in_group("medallas").size() <= 1: 
		$HUD/Mensaje.text = "¡Misión cumplida!"

func activar_poder():
	modo_poder = true
	print("poder: sí")
	# El temporizador durará 8.0 segundos antes de continuar
	await get_tree().create_timer(8.0).timeout 
	modo_poder = false
	print("poder: no")
				
