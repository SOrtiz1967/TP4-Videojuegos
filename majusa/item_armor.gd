extends Area2D

@export var cantidad_curacion: int = 20
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween=create_tween().set_loops()
	tween.tween_property(self, "position:y", position.y - 5, 1.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position:y", position.y + 5, 1.0).set_trans(Tween.TRANS_SINE)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func _on_body_entered(body: Node2D) -> void:
	if body is JugadorBase:
		if body.has_method("curar"):
			body.curar(cantidad_curacion)
			print("poty gorda glu glu, te suma ", cantidad_curacion, " de vida.")
			queue_free() # Destruimos el ítem del mapa
