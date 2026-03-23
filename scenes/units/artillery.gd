extends BaseUnit

const CANNONBALL_SCENE = preload("res://scenes/units/cannonball.tscn")
const FIRE_INTERVAL: float = 2.0
const RANGED_DETECTION: float = 400.0
const MELEE_FALLBACK_DAMAGE: float = 3.0
const CANNONBALL_DAMAGE: float = 25.0

var fire_timer: float = 0.0
var is_firing: bool = false

func _ready():
	unit_type = "artillery"
	max_health = 60.0
	speed = 40.0
	melee_damage = MELEE_FALLBACK_DAMAGE
	detection_radius = RANGED_DETECTION
	strong_against = "cavalry"
	super._ready()

func _physics_process(delta):
	if not is_alive:
		return

	fire_timer -= delta

	var ranged_target = find_ranged_target()

	if ranged_target:
		is_firing = true
		velocity = Vector2.ZERO  # Stationary when firing
		if fire_timer <= 0:
			fire_cannonball(ranged_target)
			fire_timer = FIRE_INTERVAL
	else:
		is_firing = false
		if is_player_controlled and is_selected:
			handle_player_input()
		elif current_target and current_target.is_alive:
			move_toward_target(current_target)

	# Melee fallback
	for body in detection_area.get_overlapping_bodies():
		if body is BaseUnit and body.team != team and body.is_alive:
			if global_position.distance_to(body.global_position) < 40:
				body.take_damage(MELEE_FALLBACK_DAMAGE * delta, self)

	move_and_slide()

func find_ranged_target() -> BaseUnit:
	var nearest = find_nearest_enemy()
	if nearest and global_position.distance_to(nearest.global_position) <= RANGED_DETECTION:
		return nearest
	return null

func fire_cannonball(target: BaseUnit) -> void:
	var ball = CANNONBALL_SCENE.instantiate()
	ball.global_position = global_position
	ball.direction = (target.global_position - global_position).normalized()
	ball.damage = CANNONBALL_DAMAGE
	ball.shooter = self  # Pass reference for bonus damage
	ball.shooter_team = team
	get_tree().current_scene.get_node("Projectiles").add_child(ball)
