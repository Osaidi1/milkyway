class_name Player
extends CharacterBody2D

@onready var animater: AnimatedSprite2D = $Animater
@onready var collision: CollisionShape2D = $Collision
@onready var coyote: Timer = $coyote

@export var WALK_SPEED: int = 55
@export var RUN_SPEED: int = 145
@export var JUMP_VELOCITY: int = -400
@export var HEALTH: int = 100

var speed: int
var direction: float
var is_jumping: bool
var is_falling: bool
var is_attacking: bool
var is_dying: bool
var is_hurting: bool
var fall_start_played: bool
var was_on_floor: bool

func _ready():
	is_dying = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("temp"):
		health_change(-30)
	if event.is_action_pressed("jump") and !is_attacking:
		if is_on_floor() or !coyote.is_stopped():
			jump()
	if event.is_action_released("attack") and !is_jumping and !is_falling:
		attack()

func _physics_process(delta: float) -> void:
	if is_dying: return
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#Set Variables
	was_on_floor = is_on_floor()
	if HEALTH <= 0:
		die()
	if is_falling:
		is_jumping = false
	if is_on_floor():
		fall_start_played = false
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
	
	#Call Funcs
	face_direction()
	
	health_set()
	
	speed_set()
	
	anims()
	
	move_and_slide()
	
	#Coyote Time
	if was_on_floor and !is_on_floor():
		coyote.start()

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
	if is_dying or is_hurting: return
	if is_jumping or velocity.y < 0:
		animater.play("jump")
	elif is_falling:
		if !fall_start_played:
			animater.play("fall start")
			fall_start_played = true
		if !animater.is_playing():
			animater.play("fall")
	elif direction != 0:
		if Input.is_action_pressed("run"):
			animater.play("run")
		else:
			animater.play("walk")
	else:
		animater.play("idle")

func attack():
	pass

func jump():
	is_jumping = true
	velocity.y = JUMP_VELOCITY

func health_set():
	HEALTH = clamp(HEALTH, 0, 100)

func health_change(diff):
	var prev_health = HEALTH
	HEALTH += diff
	if prev_health > HEALTH:
		is_hurting = true
		animater.play("hurt")
		await get_tree().create_timer(0.624).timeout
		is_hurting = false

func die():
	is_dying = true
	animater.play("death")
	await get_tree().create_timer(2.5).timeout
	get_tree().reload_current_scene()

func in_void(body: Node2D) -> void:
	if body is Player:
		await get_tree().create_timer(1).timeout
		get_tree().reload_current_scene()
