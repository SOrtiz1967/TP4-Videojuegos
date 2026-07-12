extends CanvasLayer

@onready var texto_vidas = $VBoxContainer/vida
@onready var texto_lanzas = $VBoxContainer/lanzas
@onready var texto_monedas = $VBoxContainer/coins

func _ready() -> void:
	var jugador = get_tree().get_first_node_in_group("jugadores")
	if jugador:
		jugador.vida_cambiada.connect(_on_vida_cambiada)
		jugador.lanzas_cambiadas.connect(_on_lanzas_cambiadas)
		jugador.monedas_cambiadas.connect(_on_monedas_cambiadas)
		_on_vida_cambiada(jugador.vidas)
		_on_lanzas_cambiadas(jugador.municion_lanza)
		_on_monedas_cambiadas(jugador.monedas_actuales)


func _on_vida_cambiada(nueva_vida: int) -> void:
	texto_vidas.text = "Vidas: " + str(nueva_vida)
func _on_lanzas_cambiadas(nuevas_lanzas: int) -> void:
	texto_lanzas.text = "Lanzas: " + str(nuevas_lanzas)
func _on_monedas_cambiadas(nuevas_monedas: int) -> void:
	texto_monedas.text = "Monedas: " + str(nuevas_monedas)
