extends CharacterBody2D

var gravedad = ProjectSettings.get_setting("physics/2d/default_gravity")
var daño_enemigo: int = 1
var vida_enemigo: int = 1 
@onready var zona_golpe = $Area2D

func _ready() -> void:
	add_to_group("enemigos")
	zona_golpe.body_entered.connect(_on_zona_golpe_body_entered)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravedad * delta
	move_and_slide()

func _on_zona_golpe_body_entered(body: Node2D) -> void:
	if body is JugadorBase:
		if body.velocity.y > 0 and body.global_position.y < global_position.y:
			if body.has_method("rebotar_en_enemigo"):
				body.rebotar_en_enemigo()
			queue_free() 
		else:
			if body.has_method("recibir_daño"):
				body.recibir_daño(daño_enemigo)
				print("ñam")
			queue_free()

func recibir_daño(daño_recibido: int) -> void:
	vida_enemigo -= daño_recibido
	print("¡Le diste al hongo! Vida restante: ", vida_enemigo)
	if vida_enemigo <= 0:
		queue_free()
