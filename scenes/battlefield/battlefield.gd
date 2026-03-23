extends Node2D

@onready var tilemap: TileMapLayer = $TileMapLayer

func _ready():
	add_to_group("battlefield")

func is_hill(world_pos: Vector2) -> bool:
	var cell = tilemap.local_to_map(tilemap.to_local(world_pos))
	var data = tilemap.get_cell_tile_data(cell)
	if data:
		return data.get_custom_data("terrain_type") == "hill"
	return false

func is_river(world_pos: Vector2) -> bool:
	var cell = tilemap.local_to_map(tilemap.to_local(world_pos))
	var data = tilemap.get_cell_tile_data(cell)
	if data:
		return data.get_custom_data("terrain_type") == "river"
	return false

func get_damage_multiplier(world_pos: Vector2) -> float:
	if is_hill(world_pos):
		return 0.75
	return 1.0
