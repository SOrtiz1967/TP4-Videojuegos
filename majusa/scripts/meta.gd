extends Area2D

signal nivel_ganado(ruta_siguiente: String)

@export var monedas_necesarias: int= 80
@export_file("*.tscn") var escena_siguiente: String

func _ready() -> void:
	add_to_group("meta")
	body_entered.connect(_al_entrar_cuerpo)

func _al_entrar_cuerpo(body: Node2D) -> void:
	if not body is JugadorBase:
		return
	if body.monedas_actuales >= monedas_necesarias:
		nivel_ganado.emit(escena_siguiente)
	else:
		return
