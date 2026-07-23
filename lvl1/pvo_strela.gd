extends Node2D

@export var pvo_name: String = "Стрела-10"
@export var cost: int = 50
@export var range_radius: float = 180.0
@export var damage: float = 30.0
@export var fire_rate: float = 0.45

var is_ghost: bool = false
var is_valid_placement: bool = true
var show_range: bool = false
var current_target: Node2D = null
var fire_timer: float = 0.0

@onready var turret_head: Node2D = $TurretHead
@onready var barrel_left: Node2D = $TurretHead/BarrelLeft
@onready var barrel_right: Node2D = $TurretHead/BarrelRight
@onready var shot_line: Line2D = $ShotLine
@onready var click_area: Area2D = $ClickArea

func _ready() -> void:
	if not is_ghost:
		click_area.mouse_entered.connect(_on_mouse_entered)
		click_area.mouse_exited.connect(_on_mouse_exited)
		click_area.input_event.connect(_on_click_area_input_event)

func _process(delta: float) -> void:
	if is_ghost:
		return
		
	_update_target()
	
	if is_instance_valid(current_target):
		# Поворот башни
		var target_angle = (current_target.global_position - turret_head.global_position).angle()
		turret_head.rotation = lerp_angle(turret_head.rotation, target_angle, delta * 12.0)
		
		fire_timer -= delta
		if fire_timer <= 0.0:
			_fire()
			fire_timer = fire_rate

func _update_target() -> void:
	if not is_instance_valid(current_target) or not current_target.is_inside_tree() or global_position.distance_to(current_target.global_position) > range_radius:
		current_target = null
		
	if current_target != null:
		return
		
	# Поиск ближайшего дрона
	var drones = get_tree().get_nodes_in_group("drones")
	var closest_dist: float = range_radius + 1.0
	var best_drone: Node2D = null
	
	for drone in drones:
		if is_instance_valid(drone) and drone.is_inside_tree():
			var dist = global_position.distance_to(drone.global_position)
			if dist <= range_radius and dist < closest_dist:
				closest_dist = dist
				best_drone = drone
				
	current_target = best_drone

func _fire() -> void:
	if not is_instance_valid(current_target):
		return
		
	# Дамаг
	if current_target.has_method("take_damage"):
		current_target.take_damage(damage)
		
	# визуальный эффект патрона
	_show_shot_effect(current_target.global_position)

func _show_shot_effect(target_pos: Vector2) -> void:
	shot_line.clear_points()
	var start_pos = barrel_left.global_position if randf() > 0.5 else barrel_right.global_position
	shot_line.add_point(to_local(start_pos))
	shot_line.add_point(to_local(target_pos))
	shot_line.visible = true
	
	var line_tween := create_tween()
	line_tween.tween_property(shot_line, "modulate:a", 0.0, 0.08)
	await line_tween.finished
	shot_line.visible = false
	shot_line.modulate.a = 1.0

func _draw() -> void:
	if is_ghost:
		var fill_color = Color(0.2, 0.9, 0.4, 0.18) if is_valid_placement else Color(1.0, 0.2, 0.2, 0.22)
		var border_color = Color(0.3, 1.0, 0.5, 0.8) if is_valid_placement else Color(1.0, 0.3, 0.3, 0.85)
		draw_circle(Vector2.ZERO, range_radius, fill_color)
		draw_arc(Vector2.ZERO, range_radius, 0, TAU, 64, border_color, 2.5)
	elif show_range:
		# радиус
		var fill_color = Color(0.15, 0.85, 0.45, 0.12)
		var border_color = Color(0.25, 0.95, 0.5, 0.65)
		draw_circle(Vector2.ZERO, range_radius, fill_color)
		draw_arc(Vector2.ZERO, range_radius, 0, TAU, 64, border_color, 2.0)
		
		for i in range(8):
			var angle = i * (TAU / 8.0)
			var inner_p = Vector2.RIGHT.rotated(angle) * (range_radius - 8)
			var outer_p = Vector2.RIGHT.rotated(angle) * (range_radius + 4)
			draw_line(inner_p, outer_p, Color(0.3, 1.0, 0.6, 0.7), 1.5)

func set_ghost_valid(valid: bool) -> void:
	is_valid_placement = valid
	modulate = Color(1, 1, 1, 0.75) if valid else Color(1, 0.4, 0.4, 0.75)
	queue_redraw()

func _on_mouse_entered() -> void:
	show_range = true
	queue_redraw()

func _on_mouse_exited() -> void:
	show_range = false
	queue_redraw()

func _on_click_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		show_range = not show_range
		queue_redraw()
