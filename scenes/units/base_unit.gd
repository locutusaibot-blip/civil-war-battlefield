extends CharacterBody2D
class_name BaseUnit

signal died(unit: BaseUnit)
signal health_changed(unit: BaseUnit, new_health: float)

@export var unit_type: String = "base"
@export var max_health: float = 100.0
@export var speed: float = 120.0
@export var melee_damage: float = 10.0
@export var detection_radius: float = 80.0
@export var team: String = "union"
@export var strong_against: String = ""

var health: float
var is_selected: bool = false
var is_alive: bool = true
var current_target: BaseUnit = null
var is_player_controlled: bool = false

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var detection_area: Area2D = $DetectionArea
@onready var sprite: Node2D = $Sprite  # ColorRect or Polygon2D

func _ready():
	health = max_health
	add_to_group(team)
	add_to_group("units")
	# Create unique detection shape per instance (avoid shared sub-resource mutation)
	var detect_shape = CircleShape2D.new()
	detect_shape.radius = detection_radius
	detection_area.get_node("CollisionShape2D").shape = detect_shape

func take_damage(amount: float, attacker: BaseUnit = null) -> void:
	if not is_alive:
		return
	# Hill defense
	var battlefield = get_tree().get_first_node_in_group("battlefield")
	if battlefield:
		amount *= battlefield.get_damage_multiplier(global_position)
	# Bonus damage from counter unit
	if attacker and attacker.strong_against == unit_type:
		amount *= 1.5
	health -= amount
	health_changed.emit(self, health)
	if health <= 0:
		health = 0
		die()

func die() -> void:
	is_alive = false
	died.emit(self)
	sprite.modulate = Color(0.3, 0.3, 0.3, 0.5)
	collision_shape.set_deferred("disabled", true)
	detection_area.monitoring = false
	detection_area.monitorable = false
	set_physics_process(false)

func set_selected(selected: bool) -> void:
	is_selected = selected
	modulate = Color(1.3, 1.3, 1.3) if selected else Color(1, 1, 1)

func get_enemy_group() -> String:
	return "confederate" if team == "union" else "union"

func find_nearest_enemy() -> BaseUnit:
	var enemies = get_tree().get_nodes_in_group(get_enemy_group())
	var nearest: BaseUnit = null
	var nearest_dist: float = INF
	for enemy in enemies:
		if enemy is BaseUnit and enemy.is_alive:
			var dist = global_position.distance_to(enemy.global_position)
			if dist < nearest_dist:
				nearest_dist = dist
				nearest = enemy
	return nearest

# --- Common movement (used by subclasses and AI) ---

func handle_player_input() -> void:
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * speed

func move_toward_target(target: BaseUnit) -> void:
	var direction = (target.global_position - global_position).normalized()
	velocity = direction * speed

func apply_melee_damage(delta: float) -> void:
	for body in detection_area.get_overlapping_bodies():
		if body is BaseUnit and body.team != team and body.is_alive:
			if global_position.distance_to(body.global_position) < 40:
				body.take_damage(melee_damage * delta, self)
				if current_target == null:
					current_target = body

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body is BaseUnit and body.team != team and body.is_alive:
		if current_target == null or not current_target.is_alive:
			current_target = body
