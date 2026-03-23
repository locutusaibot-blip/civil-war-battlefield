extends Node

signal game_state_changed(new_state: String)
signal unit_selected(unit: BaseUnit)

enum GameState { SETUP, COUNTDOWN, BATTLE, PAUSED, VICTORY, DEFEAT, DRAW }

var state: GameState = GameState.SETUP
var selected_unit: BaseUnit = null
var player_units: Array[BaseUnit] = []
var enemy_units: Array[BaseUnit] = []
var countdown_timer: float = 2.0
var stalemate_timer: float = 15.0

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta):
	match state:
		GameState.COUNTDOWN:
			countdown_timer -= delta
			if countdown_timer <= 0:
				start_battle()
		GameState.BATTLE:
			check_victory_conditions()
			check_stalemate(delta)

func _unhandled_input(event):
	if event.is_action_pressed("pause") and (state == GameState.BATTLE or state == GameState.PAUSED):
		toggle_pause()
	elif event.is_action_pressed("restart") and state in [GameState.VICTORY, GameState.DEFEAT, GameState.DRAW]:
		restart_game()
	elif state == GameState.BATTLE:
		handle_unit_selection(event)

func setup_game(p_units: Array[BaseUnit], e_units: Array[BaseUnit]) -> void:
	player_units = p_units
	enemy_units = e_units

	for unit in player_units:
		unit.is_player_controlled = true
		unit.died.connect(_on_unit_died)
		unit.health_changed.connect(_on_damage_dealt)

	for unit in enemy_units:
		unit.is_player_controlled = false
		unit.died.connect(_on_unit_died)
		unit.health_changed.connect(_on_damage_dealt)

	if player_units.size() > 0:
		select_unit(player_units[0])

	state = GameState.COUNTDOWN
	countdown_timer = 2.0
	game_state_changed.emit("countdown")

func start_battle() -> void:
	state = GameState.BATTLE
	stalemate_timer = 15.0
	game_state_changed.emit("battle")

func handle_unit_selection(event: InputEvent) -> void:
	if event.is_action_pressed("select_unit_1"):
		select_unit_by_index(0)
	elif event.is_action_pressed("select_unit_2"):
		select_unit_by_index(1)
	elif event.is_action_pressed("select_unit_3"):
		select_unit_by_index(2)
	elif event.is_action_pressed("cycle_unit"):
		cycle_unit()

func select_unit_by_index(index: int) -> void:
	if index < player_units.size() and player_units[index].is_alive:
		select_unit(player_units[index])

func cycle_unit() -> void:
	var living = player_units.filter(func(u): return u.is_alive)
	if living.is_empty():
		return
	var current_index = living.find(selected_unit)
	var next_index = (current_index + 1) % living.size()
	select_unit(living[next_index])

func select_unit(unit: BaseUnit) -> void:
	if selected_unit:
		selected_unit.set_selected(false)
	selected_unit = unit
	selected_unit.set_selected(true)
	unit_selected.emit(unit)

func check_victory_conditions() -> void:
	var player_alive = player_units.filter(func(u): return u.is_alive)
	var enemy_alive = enemy_units.filter(func(u): return u.is_alive)
	if enemy_alive.is_empty():
		state = GameState.VICTORY
		game_state_changed.emit("victory")
	elif player_alive.is_empty():
		state = GameState.DEFEAT
		game_state_changed.emit("defeat")

func check_stalemate(delta: float) -> void:
	stalemate_timer -= delta
	if stalemate_timer <= 0:
		var p_hp = player_units.filter(func(u): return u.is_alive).reduce(func(acc, u): return acc + u.health, 0.0)
		var e_hp = enemy_units.filter(func(u): return u.is_alive).reduce(func(acc, u): return acc + u.health, 0.0)
		if p_hp > e_hp:
			state = GameState.VICTORY
			game_state_changed.emit("victory")
		elif e_hp > p_hp:
			state = GameState.DEFEAT
			game_state_changed.emit("defeat")
		else:
			state = GameState.DRAW
			game_state_changed.emit("draw")

func _on_damage_dealt(_unit: BaseUnit, _new_health: float) -> void:
	stalemate_timer = 15.0  # Reset on any damage

func _on_unit_died(_unit: BaseUnit) -> void:
	stalemate_timer = 15.0

func toggle_pause() -> void:
	if state == GameState.BATTLE:
		state = GameState.PAUSED
		get_tree().paused = true
		game_state_changed.emit("paused")
	elif state == GameState.PAUSED:
		state = GameState.BATTLE
		get_tree().paused = false
		game_state_changed.emit("battle")

func restart_game() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
