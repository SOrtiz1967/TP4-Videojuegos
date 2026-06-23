extends CharacterBody2D

@export var velocidad: float = 200.0
@export var fuerza_salto: float = -400.0

var gravedad = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var sprite = $AnimatedSprite2D

enum Estado{
	REPOSO,
	CORRER,
	AIRE,
	ATACAR,
	RECIBIR_GOLPE,
	MORIR
}#manteca

var estado_actual: Estado=Estado.REPOSO
var combo_ataque: int=1 

func _ready() -> void:
	sprite.animation_finished.connect(_on_animated_sprite_2d_animation_finished)

func _physics_process(delta: float) -> void:
	if estado_actual != Estado.MORIR and not is_on_floor():
		velocity.y+=gravedad * delta

	match estado_actual:
		Estado.REPOSO:
			estado_reposo()
		Estado.CORRER:
			estado_correr()
		Estado.AIRE:
			estado_aire()
		Estado.ATACAR:
			estado_atacar()
		Estado.RECIBIR_GOLPE:
			estado_recibir_golpe()
		Estado.MORIR:
			estado_morir()

	move_and_slide()

# estados

func estado_reposo():
	sprite.play("reposo")
	velocity.x=move_toward(velocity.x, 0, velocidad)

	if not is_on_floor():
		estado_actual=Estado.AIRE
	elif Input.is_action_just_pressed("saltar"):
		ejecutar_salto()
	elif Input.is_action_just_pressed("atacar"):
		iniciar_ataque()
	elif Input.get_axis("izquierda", "derecha") != 0:
		estado_actual=Estado.CORRER

func estado_correr():
	sprite.play("correr")
	var direccion=Input.get_axis("izquierda", "derecha")

	if direccion!=0:
		velocity.x=direccion * velocidad
		sprite.flip_h=(direccion < 0)
	else:
		estado_actual=Estado.REPOSO

	if not is_on_floor():
		estado_actual=Estado.AIRE
	elif Input.is_action_just_pressed("saltar"):
		ejecutar_salto()
	elif Input.is_action_just_pressed("atacar"):
		iniciar_ataque()

func estado_aire():
	if velocity.y < 0:
		sprite.play("saltar")
	else:
		sprite.play("caer")

	var direccion = Input.get_axis("izquierda", "derecha")
	
	if direccion != 0:
		velocity.x=direccion * velocidad
		sprite.flip_h=(direccion < 0)
	else:
		velocity.x=move_toward(velocity.x, 0, velocidad)

	if is_on_floor():
		if direccion!= 0:
			estado_actual =Estado.CORRER
		else:
			estado_actual= Estado.REPOSO

func iniciar_ataque():
	estado_actual= Estado.ATACAR
	sprite.play("atacar" + str(combo_ataque))

func estado_atacar():
	velocity.x =move_toward(velocity.x, 0, velocidad)

func estado_recibir_golpe():
	sprite.play("recibir_golpe")
	velocity.x=move_toward(velocity.x, 0, velocidad)

func estado_morir():
	sprite.play("morir")
	velocity.x = move_toward(velocity.x, 0, velocidad)

func ejecutar_salto():
	velocity.y=fuerza_salto
	estado_actual= Estado.AIRE

# señales mantecosas

func _on_animated_sprite_2d_animation_finished() -> void:
	if estado_actual == Estado.ATACAR:
		combo_ataque+=1
		if combo_ataque>3:
			combo_ataque= 1 
			
		estado_actual= Estado.REPOSO
		
	elif estado_actual == Estado.RECIBIR_GOLPE:
		estado_actual = Estado.REPOSO
