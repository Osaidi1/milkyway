class_name Skeleton
extends CharacterBody2D

@onready var timer: Timer = $Timer
@onready var animater: AnimatedSprite2D = $Animater
@onready var turn: RayCast2D = $Animater/Turn
@onready var hurtbox: Area2D = $Hurtbox
@onready var hitbox: Area2D = $Hitbox
@onready var hit_collision: CollisionShape2D = $Hitbox/CollisionShape2D

@export var HEALTH := 100
@export var SPEED := 50
@export var player: CharacterBody2D

var rng := RandomNumberGenerator.new()
var player_pos: Vector2

var dir := 1
var last_dir := dir
var friction := 0.9
var is_chasing := false
var is_attacking := false
var is_hurting := false
var is_wandering := true
var is_walking := true
var is_stopped := false

func _ready() -> void:
	hit_collision.disabled = true
	random_time()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#Chase Logic
	if is_chasing:
		#No Wander while chase
		is_wandering = false
		
		#Get Player Position
		player_pos = player.global_position
		
		#Move Toward Player
		var direction = (player_pos - position).normalized()
		velocity.x = direction.x * SPEED * 1.5
		
		#Turn while chase
		dir = sign(direction.x)
		
		#No Move while Attack
		if is_attacking:
			velocity.x = 0
	
	#Wander Logic
	if is_wandering:
		#No Chase while wander
		is_chasing = false
		
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

func facing_dir() -> void:
	if dir != last_dir:
		animater.flip_h = dir < 0
		turn.position.x *= -1
		last_dir = dir
		hurtbox.scale.x = dir
		hitbox.scale.x = dir

func random_time() -> void:
	if is_wandering:
		timer.wait_time = rng.randf_range(4.0, 7.0)
		is_walking = true
		is_stopped = false

func timer_end() -> void:
	if is_wandering:
		is_walking = false
		is_stopped = true
		await get_tree().create_timer(rng.randf_range(1.0, 2.5)).timeout
		random_time()
		timer.start()

func anims() -> void:
	if is_attacking: return
	if is_chasing:
		animater.play("chase walk")
	elif is_walking:
		animater.play("walk")
	elif is_stopped:
		animater.play("idle")

func player_in_range(body: Node2D) -> void:
	if body is Player:
		is_chasing = true
		is_wandering = false

func player_not_in_range(body: Node2D) -> void:
	if body is Player:
		animater.play("idle")
		is_chasing = false
		velocity.x = 0
		await get_tree().create_timer(2).timeout
		is_wandering = true

func attack(body: Node2D) -> void:
	if body is Player:
		is_attacking = true
		while is_attacking:
			animater.play("attack")
			await get_tree().create_timer(0.2).timeout
			hit_collision.disabled = false
			await get_tree().create_timer(0.2).timeout
			hit_collision.disabled = true
			await get_tree().create_timer(0.2).timeout
			hit_collision.disabled = false
			await get_tree().create_timer(0.2).timeout
			hit_collision.disabled = true
			await get_tree().create_timer(0.3).timeout

func attack_exit(body: Node2D) -> void:
	if body is Player:
		is_attacking = false

func health_set() -> void:
	HEALTH = clamp(HEALTH, 0, 100)

func health_change(diff) -> void:
	var prev_health = HEALTH
	HEALTH += diff
	if prev_health > HEALTH:
		is_hurting = true
		animater.play("hurt")
		await get_tree().create_timer(0.5).timeout
		is_hurting = false

func player_hurt_entered(_area: Area2D) -> void:
	player.health_change(-20)
