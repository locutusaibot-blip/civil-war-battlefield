extends BaseUnit

func _ready():
	unit_type = "infantry"
	max_health = 100.0
	speed = 120.0
	melee_damage = 10.0
	detection_radius = 80.0
	strong_against = "artillery"
	super._ready()

func _physics_process(delta):
	if not is_alive:
		return

	if is_player_controlled and is_selected:
		handle_player_input()
	elif current_target and current_target.is_alive:
		move_toward_target(current_target)
	# else: velocity stays as set by AI controller (or zero)

	apply_melee_damage(delta)
	move_and_slide()
