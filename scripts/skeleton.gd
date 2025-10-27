class_name Skeleton
extends CharacterBody2D

@onready var timer: Timer = $Timer

@export var SPEED: int = 50

var dir: Vector2
var is_chasing = false
var is_attacking = false
var is_hurting = false
var is_idling = true
var is_walking = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#Move Logic
	if is_walking:
		move(delta)
	
	#Move
	move_and_slide()

func _on_timer_timeout() -> void:
	if !is_chasing or !is_hurting or !is_attacking:
		timer.wait_time = choose([0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.25, 2.5])
		dir = choose([Vector2.LEFT, Vector2.RIGHT])
		if is_idling:
			is_idling = false
			is_walking = true
		if is_walking:
			is_walking = false
			is_idling = true

func choose(array):
	array.shuffle()
	return array.front()

func move(delta):
	velocity += dir * SPEED * delta
