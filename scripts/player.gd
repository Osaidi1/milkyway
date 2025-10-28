class_name Player
extends CharacterBody2D

@onready var animater: AnimatedSprite2D = $Animater
@onready var collision: CollisionShape2D = $Collision
@onready var coyote: Timer = $coyote
@onready var side: RayCast2D = $Animater/side
@onready var side2: RayCast2D = $Animater/side2
@onready var combo_timer: Timer = $combo
@onready var cooldown: Timer = $cooldown
@onready var jump_buffer: Timer = $"jump buffer"

@export var WALK_SPEED: int = 55
@export var RUN_SPEED: int = 145
@export var DASH_SPEED: int = 500
@export var JUMP_VELOCITY: int = -400
@export var HEALTH: int = 100
@export var SLIDE_FRICTION: int = 60
@export var WALL_JUMP_POWER: int = 100

enum attack_state {Att1, Att2, Att3}

var speed: int
var direction: float
var is_jumping: bool
var is_falling: bool
var is_attacking: bool
var is_dashing: bool
var is_dying: bool
var is_hurting: bool
var is_in_wall: bool
var is_wall_jumping: bool
var is_hanging: bool
var fall_start_played: bool
var was_on_floor: bool
var dash_time: float
var dash_duration: float = 0.35
var looking_toward: int = 1
var wall_jump_lock: float = 0.0
var wall_jump_lock_time: float = 0.2
var wall_stay: float = 0.0
var wall_stay_time: float = 0.05
var att_state: int = 1
var can_attack: bool = true

func _ready():
	is_dying = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	#Dash
	if Input.is_action_just_pressed("dash") and !is_attacking and !is_dying and !is_hurting and !is_in_wall and !is_dashing and vars.dash_unlocked:
		dash()
	
	#Jump
	if is_on_floor() or !coyote.is_stopped() or is_in_wall:
		if event.is_action_pressed("jump") and !is_attacking and !is_dying and !is_hurting and !is_jumping and vars.jump_unlocked:
			jump()
	
	#Attack
	if event.is_action_released("attack") and !is_jumping and !is_falling and !is_dying and !is_hurting and !is_in_wall and can_attack and vars.attack_unlocked:
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
	if is_on_wall():
		is_wall_jumping = false
		is_dashing = false
	if is_on_floor():
		fall_start_played = false
		is_falling = false
		is_wall_jumping = false
	
	#Falling
	if !Input.is_action_just_pressed("jump") and velocity.y > 0:
		is_falling = true
		velocity.y *= 1.02
		velocity.normalized()
	
	#Jump Buffer
	if Input.is_action_pressed("jump"):
		jump_buffer.start()
	if is_on_floor() and !jump_buffer.is_stopped() and vars.jump_unlocked:
		velocity.y = JUMP_VELOCITY 
	
	#Variable Jump Height
	if !is_on_floor():
		if Input.is_action_just_released("jump") or is_on_ceiling():
			velocity *= 0.7
	
	# Get the input direction and handle the movement/deceleration.
	direction = Input.get_axis("left", "right")
	if wall_jump_lock > 0:
		wall_jump_lock -= delta
		velocity.x = move_toward(velocity.x, velocity.x, 0.2)
	elif wall_jump_lock <= 0:
		if direction:
			if !is_dashing or !is_wall_jumping:
				velocity.x = direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
	
	#Stop Moving if Attacking
	if is_attacking:
		velocity.x = 0
	
	#Dash Logic
	if is_dashing:
		dash_time += delta
		if dash_time <= dash_duration:
			var half_duration = dash_duration * 0.5
			if dash_time < half_duration:
				velocity.x = DASH_SPEED * looking_toward
			else:
				var t = (dash_time - half_duration) / half_duration
				var slowed_speed = lerp(DASH_SPEED, speed, t)
				velocity.x = slowed_speed * looking_toward
		else:
			var target_speed = max(speed + 20, DASH_SPEED * 0.5) * looking_toward
			velocity.x = move_toward(velocity.x, target_speed, 3000 * delta)
		if dash_time >= dash_duration:
			is_dashing = false
	
	#Call Funcs
	face_direction()
	
	wall_logic()
	
	health_set()
	
	speed_set()
	
	anims()
	
	move_and_slide()
	
	#Coyote Time
	if (was_on_floor and !is_on_floor()) or (is_in_wall and Input.is_action_just_pressed("jump")):
		coyote.start()
	if is_on_floor() and !coyote.is_stopped():
		coyote.stop()

func speed_set():
	if Input.is_action_pressed("run"):
		speed = RUN_SPEED
	else:
		speed = WALK_SPEED

func face_direction():
	if is_in_wall: return
	if direction < 0 or (is_in_wall and (Input.is_action_just_pressed("jump") or is_on_floor())):
		animater.flip_h = true
		looking_toward = -1
		side.target_position = Vector2(-6.5, 0)
		side2.target_position = Vector2(-6.5, 0)
	elif direction > 0 or (is_in_wall and (Input.is_action_just_pressed("jump") or is_on_floor())):
		animater.flip_h = false
		looking_toward = 1
		side.target_position = Vector2(6.5, 0)
		side2.target_position = Vector2(6.5, 0)

func anims():
	if is_dying or is_hurting or is_attacking: return
	if is_dashing:
		animater.play("dash")
	elif is_in_wall:
		animater.play("wall slide")
	elif is_wall_jumping:
		animater.play("wall jump")
	elif is_jumping or velocity.y < 0 and vars.jump_unlocked:
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
	if is_attacking: return
	if att_state == 1:
		is_attacking = true
		animater.play("attack 1")
		await get_tree().create_timer(0.27).timeout
		animater.play("attack 1 recover")
		await get_tree().create_timer(0.443).timeout
		is_attacking = false
		can_attack = false
		combo_timer.start()
		cooldown.start()
		att_state = 2
	elif att_state == 2:
		is_attacking = true
		animater.play("attack 2")
		await get_tree().create_timer(0.5).timeout
		animater.play("attack 2 recover")
		await get_tree().create_timer(0.44).timeout
		is_attacking = false
		can_attack = false
		combo_timer.start()
		cooldown.start()
		att_state = 3
	elif att_state == 3:
		is_attacking = true
		animater.play("attack 3")
		await get_tree().create_timer(1).timeout
		animater.play("attack 3 recover")
		await get_tree().create_timer(0.5).timeout
		is_attacking = false
		can_attack = false
		combo_timer.start()
		cooldown.start()
		att_state = 1

func jump():
	if is_attacking: return
	is_jumping = true
	velocity.y = JUMP_VELOCITY
	if is_in_wall:
		velocity.x = WALL_JUMP_POWER * -looking_toward
		is_wall_jumping = true
		is_in_wall = false
		wall_jump_lock = wall_jump_lock_time

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

func dash():
	is_dashing = true
	dash_time = 0.0

func in_void(body: Node2D) -> void:
	if body is Player:
		await get_tree().create_timer(1).timeout
		get_tree().reload_current_scene()

func wall_logic():
	if side.is_colliding() and side2.is_colliding() and !is_on_floor() and velocity.y > 0 and vars.wall_slide_jump_unlocked:
		velocity.x = 0
		is_in_wall = true
		wall_stay = wall_stay_time
		if Input.is_action_pressed("down"):
			velocity.y = SLIDE_FRICTION * 3
		else:
			velocity.y = SLIDE_FRICTION
	else:
		is_in_wall = false

func combo_end() -> void:
	att_state = 1 

func cooldown_end() -> void:
	can_attack = true
