extends CanvasLayer

func _ready() -> void:
	visible = false
	call_deferred("conectar_jugador")

func conectar_jugador() -> void:
	var jugador = get_tree().get_first_node_in_group("jugadores")
	if jugador:
		jugador.murio.connect(_al_morir)

func _al_morir() -> void:
	visible = true
	get_tree().paused = true

func _on_reiniciar_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_principal_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
