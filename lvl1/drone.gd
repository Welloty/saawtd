extends CharacterBody2D

@export var speed: float = 100
@export var max_health: float = 80.0
@export var reward_money: int = 20
@export var path_follower: PathFollow2D

var health: float = 80.0

func _ready() -> void:
	add_to_group("drones")
	health = max_health

func _exit_tree() -> void:
	_cleanup_path_follower()

func _cleanup_path_follower() -> void:
	if is_instance_valid(path_follower):
		path_follower.queue_free()

func _physics_process(delta: float) -> void:
	if not is_instance_valid(path_follower):
		return
	path_follower.progress += speed * delta
	if path_follower.progress_ratio >= 0.99:
		path_follower.progress_ratio = 0.0
		global_position = path_follower.global_position
		
	var target_position = path_follower.global_position
	var direction = global_position.direction_to(target_position)
	var distance = global_position.distance_to(target_position)
	if distance > 2.0:
		velocity = direction * speed
		look_at(target_position)
	else:
		velocity = Vector2.ZERO
		
	move_and_slide()

func take_damage(amount: float) -> void:
	health -= amount
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color(2.5, 0.4, 0.4, 1.0), 0.06)
	tween.tween_property(self, "modulate", Color.WHITE, 0.06)
	
	if health <= 0:
		_die()

func _die() -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("add_money"):
		hud.add_money(reward_money)
	
	# эффект смерти
	set_physics_process(false)
	remove_from_group("drones")
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", scale * 1.3, 0.15)
	tween.tween_property(self, "modulate:a", 0.0, 0.15)
	await tween.finished
	queue_free()
