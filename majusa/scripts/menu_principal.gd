extends Control

func _on_boton_jugar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/nivel_1.tscn")

func _on_boton_opciones_pressed() -> void:
	pass

func _on_boton_salir_pressed() -> void:
	get_tree().quit()
