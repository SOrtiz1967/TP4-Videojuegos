extends CharacterBody2D

@export var escena_flecha: PackedScene
@export var vida: int= 2
@export var daño: int= 1
@export var mira_derecha: bool= true
@export var cadencia_daño: float= 0.8

var muerto: bool= false
var reloj_daño: float= 0.0

@onready var animacion= $AnimatedSprite2D
@onready var temporizador= $TemporizadorDisparo
@onready var punto_disparo= $PuntoDisparo
@onready var zona_daño= $ZonaDaño

func _ready() -> void:
	add_to_group("enemigos")
	animacion.flip_h= not mira_derecha
	temporizador.timeout.connect(_disparar)
	animacion.play("reposo")

func _physics_process(delta: float) -> void:
	if muerto:
		return
	aplicar_daño_contacto(delta)

func _disparar() -> void:
	if muerto or not escena_flecha:
		return
	animacion.play("atacar")
	var flecha= escena_flecha.instantiate()
	var desplazamiento= punto_disparo.position
	if not mira_derecha:
		desplazamiento.x= -desplazamiento.x
	flecha.global_position= global_position + desplazamiento
	flecha.daño= daño
	if mira_derecha:
		flecha.direccion= Vector2(1, 0)
		flecha.rotation_degrees= 0
	else:
		flecha.direccion= Vector2(-1, 0)
		flecha.rotation_degrees= 180
	get_parent().add_child(flecha)

func aplicar_daño_contacto(delta: float) -> void:
	reloj_daño-= delta
	if reloj_daño > 0.0:
		return
	for cuerpo in zona_daño.get_overlapping_bodies():
		if cuerpo is JugadorBase and cuerpo.has_method("recibir_daño"):
			cuerpo.recibir_daño(daño)
			reloj_daño= cadencia_daño
			return

func recibir_daño(cantidad: int) -> void:
	if muerto:
		return
	vida-= cantidad
	if vida <= 0:
		morir()
	else:
		animacion.play("golpe")

func morir() -> void:
	muerto= true
	temporizador.stop()
	zona_daño.set_deferred("monitoring", false)
	animacion.play("morir")
	await animacion.animation_finished
	queue_free()
