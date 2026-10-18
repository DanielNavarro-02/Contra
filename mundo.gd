extends "res://bloques.gd"
# El nivel se arma a partir del MAPA: cada "#" es un bloque.

const MAPA = [
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"#            #           #             #",
	"#            #     #     #             #",
	"########################################",
]


func _ready():
	construir_bloques(MAPA, Color(0.45, 0.35, 0.2, 1))
