extends Node

enum AIState { ADVANCE, ENGAGE, RETREAT, ARTILLERY_HOLD }

var units: Array[BaseUnit] = []
var unit_states: Dictionary = {}
var decision_timer: float = 0.0
const DECISION_INTERVAL: float = 0.5

func setup(ai_units: Array[BaseUnit]) -> void:
	units = ai_units
	for unit in units:
		unit_states[unit] = AIState.ADVANCE

func _physics_process(_delta):
	decision_timer -= _delta
	if decision_timer <= 0:
		decision_timer = DECISION_INTERVAL
		make_decisions()
	apply_velocities()

func make_decisions() -> void:
	for unit in units:
		if not unit.is_alive:
			continue
		unit_states[unit] = evaluate_unit(unit)

func evaluate_unit(unit: BaseUnit) -> AIState:
	if unit.unit_type == "artillery":
		return AIState.ARTILLERY_HOLD

	var living = units.filter(func(u): return u.is_alive)

	# Last unit: always engage
	if living.size() == 1:
		return AIState.ENGAGE

	# Low health: retreat (unless enemy is very close)
	if unit.health < unit.max_health * 0.3:
		var nearest = unit.find_nearest_enemy()
		if nearest and unit.global_position.distance_to(nearest.global_position) < unit.detection_radius:
			return AIState.ENGAGE
		return AIState.RETREAT

	# Enemy in range: engage
	var nearest = unit.find_nearest_enemy()
	if nearest and unit.global_position.distance_to(nearest.global_position) < unit.detection_radius * 2:
		return AIState.ENGAGE

	return AIState.ADVANCE

func apply_velocities() -> void:
	for unit in units:
		if not unit.is_alive:
			continue
		# Only set velocity for AI units that aren't targeting on their own
		var state = unit_states.get(unit, AIState.ADVANCE)
		match state:
			AIState.ADVANCE:
				var target_pos = Vector2(640, 360)
				var direction = (target_pos - unit.global_position).normalized()
				unit.velocity = direction * unit.speed * 0.6
			AIState.ENGAGE:
				var target = find_best_target(unit)
				if target:
					unit.current_target = target
				# Let the unit's own _physics_process handle movement toward current_target
			AIState.RETREAT:
				var retreat_pos = Vector2(100, unit.global_position.y)
				var direction = (retreat_pos - unit.global_position).normalized()
				unit.velocity = direction * unit.speed * 0.5
			AIState.ARTILLERY_HOLD:
				unit.velocity = Vector2.ZERO
				var nearest = unit.find_nearest_enemy()
				if nearest:
					unit.current_target = nearest

func find_best_target(unit: BaseUnit) -> BaseUnit:
	var enemies = get_tree().get_nodes_in_group(unit.get_enemy_group())
	var best: BaseUnit = null
	var best_score: float = -INF
	for enemy in enemies:
		if not enemy is BaseUnit or not enemy.is_alive:
			continue
		var score: float = 0.0
		var dist = unit.global_position.distance_to(enemy.global_position)
		if unit.strong_against == enemy.unit_type:
			score += 100.0
		score -= dist * 0.1
		score += (enemy.max_health - enemy.health) * 0.5
		if score > best_score:
			best_score = score
			best = enemy
	return best
