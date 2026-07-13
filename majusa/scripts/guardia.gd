extends CharacterBody2D

@export var velocidad: float= 75.0
@export var vida: int= 3
@export var daño: int= 1
@export var cadencia_daño: float= 0.7
@export var rango_deteccion: float= 220.0

var direccion: int= 1
var muerto: bool= false
var en_golpe: bool= false
var desplazamiento_rayo: float= 0.0
var reloj_daño: float= 0.0
var gravedad= ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animacion= $AnimatedSprite2D
@onready var rayo_piso= $RayCastPiso
@onready var zona_daño= $ZonaDaño

func _ready() -> void:
	add_to_group("enemigos")
	desplazamiento_rayo= rayo_piso.position.x

func _physics_process(delta: float) -> void:
	if muerto:
		return
	if not is_on_floor():
		velocity.y+= gravedad * delta
	perseguir()
	if not rayo_piso.is_colliding():
		velocity.x= 0.0
	var moviendose= abs(velocity.x) > 1.0
	move_and_slide()
	if not en_golpe and is_on_floor():
		if moviendose:
			animacion.play("caminar")
		else:
			animacion.play("reposo")
	aplicar_daño_contacto(delta)

func perseguir() -> void:
	var jugador= get_tree().get_first_node_in_group("jugadores")
	if jugador == null:
		velocity.x= 0.0
		return
	var distancia_x= jugador.global_position.x - global_position.x
	if abs(distancia_x) > rango_deteccion:
		velocity.x= 0.0
		return
	if distancia_x < -8.0:
		direccion= -1
	elif distancia_x > 8.0:
		direccion= 1
	animacion.flip_h= direccion < 0
	rayo_piso.position.x= desplazamiento_rayo * direccion
	velocity.x= direccion * velocidad

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
		en_golpe= true
		animacion.play("golpe")
		await animacion.animation_finished
		en_golpe= false

func morir() -> void:
	muerto= true
	velocity= Vector2.ZERO
	zona_daño.set_deferred("monitoring", false)
	animacion.play("morir")
	await animacion.animation_finished
	queue_free()
