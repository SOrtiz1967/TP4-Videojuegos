extends Area2D
@export var item: PackedScene 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#chiche
	var tween=create_tween().set_loops()
	tween.tween_property(self, "position:y", position.y - 5, 1.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position:y", position.y + 5, 1.0).set_trans(Tween.TRANS_SINE)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body is JugadorBase:
		body.equipar(item)
		queue_free()
