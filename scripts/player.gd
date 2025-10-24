extends CharacterBody2D

@onready var animater: AnimatedSprite2D = $Animater
@onready var collision: CollisionShape2D = $Collision

@export var WALK_SPEED: int = 55
@export var RUN_SPEED: int = 145
@export var JUMP_VELOCITY: int = -400

var speed: int
var direction: float
var is_jumping: bool
var is_falling: bool
var is_attacking: bool

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and is_on_floor() and !is_attacking:
		jump()
	if event.is_action_released("attack") and !is_jumping and !is_falling:
		attack()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#Set Variables
	if is_on_floor():
		is_jumping = false
		is_falling = false
	
	#Falling
	if !Input.is_action_just_pressed("jump") and velocity.y > 0:
		is_falling = true
		
	# Get the input direction and handle the movement/deceleration.
	direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	face_direction()
	
	speed_set()
	
	anims()
	
	move_and_slide()

func speed_set():
	if Input.is_action_pressed("run"):
		speed = RUN_SPEED
	else:
		speed = WALK_SPEED

func face_direction():
	if direction < 0:
		animater.flip_h = true
	elif direction > 0:
		animater.flip_h = false
	elif direction == 0:
		pass

func anims():
	if is_jumping:
		animater.play("jump")
	elif is_falling:
		animater.play("fall")
	elif direction:
		if Input.is_action_pressed("run"):
			animater.play("run")
		else:
			animater.play("walk")
	

func attack():
	pass

func jump():
	velocity.y = JUMP_VELOCITY
