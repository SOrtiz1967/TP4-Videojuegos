extends CharacterBody2D
class_name JugadorBase

signal vida_cambiada(nueva_vida: int)

@export var escena_lanza: PackedScene
@export var vida_maxima: int= 5
@export var velocidad: float= 200.0
@export var fuerza_salto: float= -400.0
@export var daño: int= 10

@export var velocidad_base: float= 150.0
@export var fuerza_empujon: float= 400.0
@export var friccion: float= 900.0

@onready var animacion= $AnimatedSprite2D
@onready var vidas: int= vida_maxima

var gravedad= ProjectSettings.get_setting("physics/2d/default_gravity")
var ultima_dir= "derecha"
var atacando: bool= false
var recibiendo_golpe: bool= false

func _ready() -> void:
	add_to_group("jugadores")

func _physics_process(delta: float) -> void:
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
		
	if is_on_floor():
		actualizar_animacion("correr")
	else:
		if velocity.y < 0:
			actualizar_animacion("saltar")
		else:
			actualizar_animacion("caer")

	move_and_slide()

func _input(event: InputEvent) -> void:
	if animacion.animation == "morir" or recibiendo_golpe:
		return
	if event.is_action_pressed("derecha") and not atacando:
		velocity.x= fuerza_empujon
	if event.is_action_pressed("izquierda") and not atacando:
		velocity.x= -fuerza_empujon
	if event.is_action_pressed("saltar") and is_on_floor() and not atacando:
		velocity.y = fuerza_salto
	if event.is_action_pressed("abajo") and is_on_floor() and not atacando:
		bajar_plataforma()
	if event.is_action_pressed("atacar") and not atacando:
		ataque_normal()
	if event.is_action_pressed("atacar_lanza") and not atacando:
		ataque_lanza()

func bajar_plataforma() -> void:
	
	set_collision_mask_value(1, false)
	await get_tree().create_timer(0.4).timeout
	#atravesar plataformas
	set_collision_mask_value(1, true)
func ataque_normal() -> void:
	atacando=true
	velocity =Vector2.ZERO 
	
	animacion.play("atacar1")
	
	#logica de ataque piña
	
	await animacion.animation_finished
	atacando=false

func ataque_lanza() -> void:
	atacando=true
	velocity=Vector2.ZERO
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
