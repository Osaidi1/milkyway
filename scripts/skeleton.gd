class_name Skeleton
extends CharacterBody2D

@onready var timer: Timer = $Timer
@onready var animater: AnimatedSprite2D = $Animater
@onready var turn: RayCast2D = $Animater/Turn

@export var SPEED: int = 50

var rng = RandomNumberGenerator.new()

var dir := 1
var last_dir := dir
var friction := 0.9
var is_chasing := false
var is_attacking := false
var is_hurting := false
var is_walking := true
var is_stopped := false

func _ready():
	random_time()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#Turn at wall
	if turn.is_colliding():
		dir *= -1
	
	#Add Velocity
	if is_walking:
		velocity.x = (SPEED * dir * delta) * 60
	elif is_stopped:
		velocity.x *= (friction * delta) * 16
	
	#Call Funcs
	facing_dir()
	
	anims()
	
	move_and_slide()

func facing_dir():
	if dir != last_dir:
		animater.flip_h = dir < 0
		turn.position.x *= -1
		last_dir = dir

func random_time():
	timer.wait_time = rng.randf_range(4.0, 7.0)
	is_walking = true
	is_stopped = false

func timer_end() -> void:
	is_walking = false
	is_stopped = true
	await get_tree().create_timer(rng.randf_range(1.0, 2.5)).timeout
	random_time()
	timer.start()

func anims():
	if is_walking:
		animater.play("walk")
	elif is_stopped:
		animater.play("idle")
