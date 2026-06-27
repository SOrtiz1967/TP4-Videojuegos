extends Area2D

@export var velocidad: float= 600.0
var daño: int= 0
var direccion: Vector2= Vector2.ZERO

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exited)

func _physics_process(delta: float) -> void:
	position+= direccion * velocidad * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemigos"):
		if body.has_method("recibir_daño"):
			body.recibir_daño(daño)
		queue_free()
		
	elif body is StaticBody2D or body is TileMapLayer:
		queue_free()

func _on_screen_exited() -> void:
	queue_free()
