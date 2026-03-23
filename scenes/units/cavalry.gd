extends BaseUnit

const CHARGE_DAMAGE: float = 20.0
const SUSTAINED_DAMAGE: float = 8.0
const CHARGE_COOLDOWN: float = 3.0

var charge_available: bool = true
var charge_timer: float = 0.0
var in_contact: bool = false

func _ready():
	unit_type = "cavalry"
	max_health = 80.0
	speed = 200.0
	melee_damage = SUSTAINED_DAMAGE
	detection_radius = 80.0
	strong_against = "infantry"
	super._ready()

func _physics_process(delta):
	if not is_alive:
		return

	# Charge cooldown — only ticks when NOT in contact with enemy
	in_contact = is_in_melee_contact()
	if not charge_available and not in_contact:
		charge_timer -= delta
		if charge_timer <= 0:
			charge_available = true

	if is_player_controlled and is_selected:
		handle_player_input()
	elif current_target and current_target.is_alive:
		move_toward_target(current_target)

	apply_charge_damage(delta)
	move_and_slide()

func is_in_melee_contact() -> bool:
	for body in detection_area.get_overlapping_bodies():
		if body is BaseUnit and body.team != team and body.is_alive:
			if global_position.distance_to(body.global_position) < 40:
				return true
	return false

func apply_charge_damage(delta):
	for body in detection_area.get_overlapping_bodies():
		if body is BaseUnit and body.team != team and body.is_alive:
			if global_position.distance_to(body.global_position) < 40:
				if charge_available:
					body.take_damage(CHARGE_DAMAGE, self)
					charge_available = false
					charge_timer = CHARGE_COOLDOWN
				else:
					body.take_damage(SUSTAINED_DAMAGE * delta, self)
				if current_target == null:
					current_target = body
