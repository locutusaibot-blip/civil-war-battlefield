extends Node2D

const INFANTRY_SCENE = preload("res://scenes/units/infantry.tscn")
const CAVALRY_SCENE = preload("res://scenes/units/cavalry.tscn")
const ARTILLERY_SCENE = preload("res://scenes/units/artillery.tscn")

@onready var game_manager: Node = $GameManager
@onready var hud: CanvasLayer = $HUD

const CONF_X = 100.0   # Confederate left side, 100px from edge
const UNION_X = 1180.0  # Union right side, 100px from edge
const CENTER_Y = 360.0
const SPACING = 80.0

func _ready():
	# Green background
	var bg = ColorRect.new()
	bg.color = Color(0.18, 0.35, 0.12)
	bg.size = Vector2(1280, 720)
	bg.z_index = -10
	add_child(bg)
	move_child(bg, 0)

	spawn_armies()

func spawn_armies() -> void:
	var player_units: Array[BaseUnit] = []
	var enemy_units: Array[BaseUnit] = []

	# Union (player) — right side, vertical column
	var u_infantry = spawn_unit(INFANTRY_SCENE, $UnionArmy, Vector2(UNION_X, CENTER_Y), "union")
	var u_cavalry = spawn_unit(CAVALRY_SCENE, $UnionArmy, Vector2(UNION_X, CENTER_Y - SPACING), "union")
	var u_artillery = spawn_unit(ARTILLERY_SCENE, $UnionArmy, Vector2(UNION_X, CENTER_Y + SPACING), "union")

	# Order matches 1/2/3 keys: infantry, cavalry, artillery
	player_units.append(u_infantry)
	player_units.append(u_cavalry)
	player_units.append(u_artillery)

	# Confederate (AI) — left side, vertical column
	var c_infantry = spawn_unit(INFANTRY_SCENE, $ConfederateArmy, Vector2(CONF_X, CENTER_Y), "confederate")
	var c_cavalry = spawn_unit(CAVALRY_SCENE, $ConfederateArmy, Vector2(CONF_X, CENTER_Y - SPACING), "confederate")
	var c_artillery = spawn_unit(ARTILLERY_SCENE, $ConfederateArmy, Vector2(CONF_X, CENTER_Y + SPACING), "confederate")

	enemy_units.append(c_infantry)
	enemy_units.append(c_cavalry)
	enemy_units.append(c_artillery)

	# Color confederate units red
	for unit in enemy_units:
		unit.get_node("Sprite").color = Color(0.8, 0.2, 0.2, 1)

	# Setup game manager
	game_manager.setup_game(player_units, enemy_units)
	game_manager.unit_selected.connect(hud.set_selected_unit)
	game_manager.game_state_changed.connect(_on_game_state_changed)

	# Setup HUD
	hud.setup(player_units, enemy_units)

	# Setup AI
	$AIController.setup(enemy_units)

func spawn_unit(scene: PackedScene, parent: Node2D, pos: Vector2, team_name: String) -> BaseUnit:
	var unit = scene.instantiate()
	unit.team = team_name
	unit.position = pos
	parent.add_child(unit)
	return unit

func _on_game_state_changed(new_state: String) -> void:
	match new_state:
		"countdown":
			hud.show_message("Battle Begins!", 2.0)
		"victory":
			hud.show_message("VICTORY!")
		"defeat":
			hud.show_message("DEFEAT!")
		"draw":
			hud.show_message("DRAW!")
		"paused":
			hud.show_message("PAUSED")
		"battle":
			hud.hide_message()
