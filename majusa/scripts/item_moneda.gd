extends Area2D

enum TipoMoneda { BRONCE, PLATA, ORO }
@export var tipo_actual: TipoMoneda = TipoMoneda.BRONCE
var valor_moneda: int = 0
@onready var animacion = $AnimatedSprite2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match tipo_actual:
		TipoMoneda.BRONCE:
			valor_moneda = 1
			animacion.play("bronce")
		TipoMoneda.PLATA:
			valor_moneda = 5
			animacion.play("plata")
		TipoMoneda.ORO:
			valor_moneda = 10
			animacion.play("oro")
	var tween = create_tween().set_loops()
	tween.tween_property(self, "position:y", position.y - 5, 1.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position:y", position.y + 5, 1.0).set_trans(Tween.TRANS_SINE)
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is JugadorBase:
		if body.has_method("recolectar_moneda"):
			body.recolectar_moneda(valor_moneda)
			queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
