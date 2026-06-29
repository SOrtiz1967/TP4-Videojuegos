extends CanvasLayer

func _ready():
	visible = false
	
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		alternar_pausa()
	
func alternar_pausa():
	visible = !visible
	get_tree().paused = visible
	
func _on_continuar_pressed():
	alternar_pausa()
	
func _on_reiniciar_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
	
func _on_salir_pressed():
	get_tree().paused = false
	get_tree().quit()
