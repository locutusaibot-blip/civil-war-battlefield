extends Area2D
class_name Cannonball

var direction: Vector2 = Vector2.ZERO
var speed: float = 300.0
var damage: float = 25.0
var shooter: BaseUnit = null  # Reference to firing unit for bonus damage calc
var shooter_team: String = ""
var lifetime: float = 3.0

func _ready():
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

func _on_body_entered(body):
	if body is BaseUnit and body.team != shooter_team and body.is_alive:
		body.take_damage(damage, shooter)
		queue_free()
