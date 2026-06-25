extends CharacterBody2D
class_name JugadorBase

signal vida_cambiada(nueva_vida: int)

@export var escena_lanza: PackedScene
@export var vida_maxima: int= 5
@export var velocidad: float= 200.0
@export var fuerza_salto: float= -400.0
@export var daño: int= 10

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
		velocity.x= move_toward(velocity.x, 0, velocidad)
		move_and_slide()
		return
	var direccion= Input.get_axis("izquierda", "derecha")
	if direccion==0:
		velocity.x=move_toward(velocity.x, 0, velocidad)
		if is_on_floor():
			actualizar_animacion("reposo")
	else:
		velocity.x=direccion * velocidad
		if direccion > 0:
			ultima_dir="derecha"
			animacion.flip_h=false
		else:
			ultima_dir="izquierda"
			animacion.flip_h=true
		if is_on_floor():
			actualizar_animacion("correr")
	if not is_on_floor():
		if velocity.y < 0:
			actualizar_animacion("saltar")
		else:
			actualizar_animacion("caer")

	move_and_slide()

func _input(event: InputEvent) -> void:
	if animacion.animation == "morir" or recibiendo_golpe:
		return
	if event.is_action_pressed("saltar") and is_on_floor() and not atacando:
		velocity.y = fuerza_salto
	if event.is_action_pressed("atacar") and not atacando:
		ataque_normal()
	if event.is_action_pressed("atacar_lanza") and not atacando:
		ataque_lanza()

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


	#logica de tiraflechaa mismo que secanucas
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
