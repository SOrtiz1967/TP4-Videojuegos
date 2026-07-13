extends Area2D

func _ready() -> void:
	#chiche pro
	var tween = create_tween().set_loops()
	tween.tween_property(self, "position:y", position.y - 5, 1.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position:y", position.y + 5, 1.0).set_trans(Tween.TRANS_SINE)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is JugadorBase:
		if body.has_method("habilitar_doble_salto"):
			body.habilitar_doble_salto()
			queue_free()
