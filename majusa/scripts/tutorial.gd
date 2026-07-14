extends Node2D

func _ready() -> void:
	var jugador = get_tree().get_first_node_in_group("jugadores")
	if jugador:
		jugador.murio.connect(_al_morir)

func _al_morir() -> void:
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
