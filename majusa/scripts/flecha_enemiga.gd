extends Area2D

@export var velocidad: float= 220.0
@export var daño: int= 1
var direccion: Vector2= Vector2.RIGHT

func _ready() -> void:
	body_entered.connect(_al_entrar_cuerpo)
	$VisibleOnScreenNotifier2D.screen_exited.connect(_al_salir_pantalla)

func _physics_process(delta: float) -> void:
	position+= direccion * velocidad * delta

func _al_entrar_cuerpo(body: Node2D) -> void:
	if body is JugadorBase:
		if body.has_method("recibir_daño"):
			body.recibir_daño(daño)
		queue_free()
	elif body is StaticBody2D or body is TileMapLayer:
		queue_free()

func _al_salir_pantalla() -> void:
	queue_free()
