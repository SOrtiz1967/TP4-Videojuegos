extends CharacterBody2D

@export var velocidad_normal: float= 55.0
@export var velocidad_embestida: float= 160.0
@export var vida: int= 4
@export var daño: int= 1
@export var cadencia_daño: float= 1.2
@export var rango_deteccion: float= 260.0

var direccion: int= 1
var muerto: bool= false
var embistiendo: bool= false
var en_golpe: bool= false
var reloj_daño: float= 0.0
var desplazamiento_rayo: float= 0.0
var gravedad= ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animacion= $AnimatedSprite2D
@onready var rayo_frontal= $RayCastFrontal
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
	var en_rango= orientar_hacia_jugador()
	if en_rango and rayo_frontal.is_colliding() and rayo_frontal.get_collider() is JugadorBase:
		embistiendo= true
	var velocidad_actual= velocidad_normal
	if embistiendo:
		velocidad_actual= velocidad_embestida
	if en_rango:
		velocity.x= direccion * velocidad_actual
	else:
		velocity.x= 0.0
	if not rayo_piso.is_colliding():
		velocity.x= 0.0
	var moviendose= abs(velocity.x) > 1.0
	move_and_slide()
	if not en_golpe:
		if not moviendose:
			animacion.play("reposo")
		elif embistiendo:
			animacion.play("atacar")
		else:
			animacion.play("caminar")
	aplicar_daño_contacto(delta)

func orientar_hacia_jugador() -> bool:
	var jugador= get_tree().get_first_node_in_group("jugadores")
	if jugador == null:
		return false
	var distancia_x= jugador.global_position.x - global_position.x
	if abs(distancia_x) > rango_deteccion:
		return false
	if distancia_x < -8.0:
		direccion= -1
	elif distancia_x > 8.0:
		direccion= 1
	animacion.flip_h= direccion < 0
	rayo_frontal.target_position.x= abs(rayo_frontal.target_position.x) * direccion
	rayo_piso.position.x= desplazamiento_rayo * direccion
	return true

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
