extends CharacterBody2D

@export var speed: float = 150
@export var path_follower: PathFollow2D

func _physics_process(delta: float) -> void:
	if not path_follower:
		return
	path_follower.progress +=speed * delta
	var target_position = path_follower.global_position
	var direction = global_position.direction_to(target_position)
	var distance = global_position.distance_to(target_position)
	if distance > 2.0:
		velocity = direction * speed
		look_at(target_position)
	else:
		velocity = Vector2.ZERO
		
	move_and_slide()
