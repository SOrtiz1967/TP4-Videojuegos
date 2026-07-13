extends CharacterBody2D
class_name JugadorBase

signal lanzas_cambiadas(cantidad: int)
signal monedas_cambiadas(cantidad: int)
signal vida_cambiada(nueva_vida: int)
@export var velocidad_acelerada: float= 250.0
@export var escena_lanza: PackedScene

@export var velocidad: float= 200.0
@export var fuerza_salto: float= -400.0
@export var daño: int= 10
@export var max_saltos: int= 1
var saltos_actuales: int= 0
@export var velocidad_base: float= 150.0
@export var fuerza_empujon: float= 400.0
@export var friccion: float= 900.0

@onready var animacion= $AnimatedSprite2D
@onready var vidas: int= vida_maxima
var municion_lanza: int = 0
var gravedad= ProjectSettings.get_setting("physics/2d/default_gravity")
var ultima_dir= "derecha"
var atacando: bool= false
var recibiendo_golpe: bool= false
var vida_maxima: int = 3
var vida_actual: int = 1
var monedas_actuales: int= 0


func _ready() -> void:
	add_to_group("jugadores")

func _physics_process(delta: float) -> void:
	
	if atacando or recibiendo_golpe:
		velocity.x=move_toward(velocity.x, 0, friccion * delta)
		move_and_slide()
		return
	var velocidad_objetivo = velocidad_base
	if is_on_floor():
		if Input.is_action_pressed("derecha"):
			velocidad_objetivo = velocidad_acelerada
	else:
		if velocity.x > velocidad_base:
			velocidad_objetivo=velocity.x
	velocity.x=move_toward(velocity.x, velocidad_objetivo, friccion * delta)
	
	if is_on_floor():
		saltos_actuales= 0
		actualizar_animacion("correr")
	else:
		if velocity.y < 0:
			actualizar_animacion("saltar")
		else:
			actualizar_animacion("caer")
	if animacion.animation == "morir":
		return
	if not is_on_floor():
		velocity.y+= gravedad * delta
	if atacando or recibiendo_golpe:
		velocity.x= move_toward(velocity.x, 0, friccion * delta)
		move_and_slide()
		return
	velocity.x= move_toward(velocity.x, velocidad_base, friccion * delta)
	
	if velocity.x >= 0:
		ultima_dir="derecha"
		animacion.flip_h=false
	else:
		ultima_dir="izquierda"
		animacion.flip_h=true
	move_and_slide()

func _input(event: InputEvent) -> void:
	if animacion.animation == "morir" or recibiendo_golpe:
		return
	if event.is_action_pressed("izquierda") and not atacando:
		velocity.x = -fuerza_empujon
	if event.is_action_pressed("derecha") and not atacando:
		velocity.x = velocidad_acelerada
	if event.is_action_released("derecha") and not atacando:
		velocity.x = velocidad_base
	
	if event.is_action_pressed("saltar") and not atacando:
		if is_on_floor():
			velocity.y = fuerza_salto
			saltos_actuales = 1
		elif saltos_actuales < max_saltos:
			velocity.y = fuerza_salto
			saltos_actuales += 1
			animacion.play("saltar")
	if event.is_action_pressed("abajo") and is_on_floor() and not atacando:
		bajar_plataforma()
	if event.is_action_pressed("atacar") and not atacando:
		ataque_normal()
	if event.is_action_pressed("atacar_lanza") and not atacando:
		ataque_lanza()

func equipar_lanza(escena_recibida: PackedScene) -> void:
	municion_lanza += 3 
	lanzas_cambiadas.emit(municion_lanza)
	print("lanzas disponibles:", municion_lanza)

func bajar_plataforma() -> void:
	
	set_collision_mask_value(1, false)
	await get_tree().create_timer(0.2).timeout
	#atravesar plataformas
	set_collision_mask_value(1, true)
func ataque_normal() -> void:
	if municion_lanza <= 0:
		print("no tenes lanza!")
		return
	atacando=true
	velocity =Vector2.ZERO 
	
	animacion.play("atacar1")
	
	#logica de ataque piña
	
	await animacion.animation_finished
	atacando=false

func ataque_lanza() -> void:
	if municion_lanza <= 0:
		print("no quedan lanzas! Tengo que agarrar otro ítem.")
		return 
		
	# 2. Descontamos una lanza porque estamos por disparar
	municion_lanza -= 1
	lanzas_cambiadas.emit(municion_lanza)
	print("¡Fiumba! Lanzas restantes: ", municion_lanza)
	
	atacando = true
	velocity = Vector2.ZERO
	
	animacion.play("lanza")
	#sincornizar la animacion con la lanza
	await get_tree().create_timer(0.55).timeout
	if escena_lanza:
		var lanza_instancia= escena_lanza.instantiate()
		
		lanza_instancia.global_position= global_position + Vector2(0, -10)
		lanza_instancia.daño= daño
		
		if ultima_dir == "derecha":
			lanza_instancia.direccion= Vector2(1, 0)
			lanza_instancia.rotation_degrees= 0
		else:
			lanza_instancia.direccion= Vector2(-1, 0)
			lanza_instancia.rotation_degrees= 180
			
		get_parent().add_child(lanza_instancia)
	if animacion.is_playing() and animacion.animation == "lanza":
		await animacion.animation_finished
	atacando = false

func recibir_daño(daño_recibido: int) -> void:
	if animacion.animation=="morir":
		return
	vidas-=daño_recibido
	vida_cambiada.emit(vidas)
	if vidas <= 0:
		animacion.play("morir")
		print("mantecoño")
	else:
		recibiendo_golpe=true
		animacion.play("recibir_golpe")
		await animacion.animation_finished
		recibiendo_golpe=false

func actualizar_animacion(estado: String) -> void:
	animacion.play(estado)


func curar(cantidad: int) -> void:
	vidas += cantidad
	vidas = min(vidas, vida_maxima)	
	print("Pickeaste armor amigo, tu vida actual es: ", vidas)
	vida_cambiada.emit(vidas) #pasasrlea al huf
	
func recolectar_moneda(valor: int) -> void:
	monedas_actuales += valor
	monedas_cambiadas.emit(monedas_actuales)
	print("pungeaste una moneda rati ", monedas_actuales)


func rebotar_en_enemigo() -> void:
	velocity.y = -800
	saltos_actuales = 1 
	print("voinki")
