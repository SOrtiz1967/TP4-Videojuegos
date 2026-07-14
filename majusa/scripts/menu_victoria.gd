extends CanvasLayer

var escena_siguiente: String = ""

func _ready() -> void:
	visible = false
	call_deferred("conectar_meta")

func conectar_meta() -> void:
	var meta = get_tree().get_first_node_in_group("meta")
	if meta:
		meta.nivel_ganado.connect(_al_ganar)

func _al_ganar(ruta_siguiente: String) -> void:
	escena_siguiente = ruta_siguiente
	visible = true
	get_tree().paused = true

func _on_siguiente_pressed() -> void:
	get_tree().paused = false
	if escena_siguiente != "":
		get_tree().change_scene_to_file(escena_siguiente)

func _on_menu_principal_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
