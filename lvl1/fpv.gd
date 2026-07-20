extends CharacterBody2D

@export var speed: float = 50
@export var path_follower: PathFollow2D
@export var propeller_speed: float = 1000.0 
@onready var propeller_lb: Sprite2D = $Propeller 
@onready var propeller_rb: Sprite2D = $Propeller2 
@onready var propeller_rf: Sprite2D = $Propeller3 
@onready var propeller_lf: Sprite2D = $Propeller4 

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
	if propeller_rb and propeller_lb and propeller_lf and propeller_rf:
		propeller_rb.rotation += propeller_speed * delta
		propeller_lb.rotation += propeller_speed * delta
		propeller_lf.rotation += propeller_speed * delta
		propeller_rf.rotation += propeller_speed * delta
	move_and_slide()
