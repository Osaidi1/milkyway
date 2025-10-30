class_name Skeleton
extends CharacterBody2D

@onready var timer: Timer = $Timer
@onready var animater: AnimatedSprite2D = $Animater
@onready var turn: RayCast2D = $Animater/Turn

@export var SPEED: int = 50

var rng = RandomNumberGenerator.new()

var dir := 1
var is_chasing := false
var is_attacking := false
var is_hurting := false
var is_walking := true 

func _ready():
	random_time()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#Rotate
	if dir > 0:
		animater.flip_h = false
		turn.position.x = -20
	if dir < 0:
		animater.flip_h = true
		turn.position.x = 20
	
	#Turn
	if turn.is_colliding():
		dir *= -1
	
	#Add Velocity
	velocity.x = SPEED * dir
	
	#Move
	move_and_slide()

func random_time():
	timer.wait_time = rng.randf_range(2, 5)

func timer_end() -> void:
	random_time()
	dir *= -1
