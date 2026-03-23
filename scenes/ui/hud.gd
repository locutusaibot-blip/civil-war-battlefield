extends CanvasLayer

@onready var player_health_container: VBoxContainer = $PlayerHealth
@onready var enemy_health_container: VBoxContainer = $EnemyHealth
@onready var selected_label: Label = $SelectedUnit
@onready var center_message: Label = $CenterMessage

var health_bars: Dictionary = {}

func setup(p_units: Array[BaseUnit], e_units: Array[BaseUnit]) -> void:
	create_health_bars(p_units, player_health_container)
	create_health_bars(e_units, enemy_health_container)
	for unit in p_units + e_units:
		unit.health_changed.connect(_on_health_changed)

func create_health_bars(units: Array[BaseUnit], container: VBoxContainer) -> void:
	for unit in units:
		var hbox = HBoxContainer.new()
		var label = Label.new()
		label.text = unit.unit_type.substr(0, 3).to_upper()
		label.custom_minimum_size = Vector2(40, 0)
		hbox.add_child(label)
		var bar = ProgressBar.new()
		bar.max_value = unit.max_health
		bar.value = unit.health
		bar.custom_minimum_size = Vector2(100, 16)
		bar.show_percentage = false
		hbox.add_child(bar)
		container.add_child(hbox)
		health_bars[unit] = bar

func _on_health_changed(unit: BaseUnit, new_health: float) -> void:
	if unit in health_bars:
		health_bars[unit].value = new_health
		if new_health <= 0:
			health_bars[unit].modulate = Color(0.5, 0.5, 0.5, 0.5)

func set_selected_unit(unit: BaseUnit) -> void:
	selected_label.text = "Selected: " + unit.unit_type.to_upper()

func show_message(text: String, duration: float = 0.0) -> void:
	center_message.text = text
	center_message.visible = true
	if duration > 0:
		await get_tree().create_timer(duration).timeout
		center_message.visible = false

func hide_message() -> void:
	center_message.visible = false
