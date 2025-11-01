class_name Slime
extends CharacterBody2D

@onready var animater: AnimatedSprite2D = $Animater
@onready var turn: RayCast2D = $Animater/Turn
@onready var attack_range: Area2D = $AttackRange
@onready var hit_collision: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var hurtbox: Area2D = $Hurtbox
@onready var hitbox: Area2D = $Hitbox
@onready var collision: CollisionShape2D = $Collision

@export var HEALTH := 60
@export var SPEED := 40
@export var player: CharacterBody2D

@export_enum("red", "orange", "yellow", "green", "blue", "peach", "gray", "pink") 
var slime_color: String = "blue"

var rng := RandomNumberGenerator.new()
var player_pos: Vector2

var dir := 1
var last_dir := dir
var friction := 0.9
var is_chasing := false
var is_attacking := false
var is_wandering := true
var is_walking := true
var is_hurting := false

func _ready() -> void:
	hit_collision.disabled = true

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
		if !is_attacking:
			velocity.x = direction.x * SPEED
		elif is_attacking:
			velocity.x = 0
		
		#Turn while chase
		dir = sign(direction.x)
	
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
	
	#Call Funcs
	facing_dir()
	
	anims()
	
	move_and_slide()

func facing_dir() -> void:
	if dir != last_dir:
		animater.flip_h = dir < 0
		turn.position.x *= -1
		turn.target_position.x *= -1
		last_dir = dir
		attack_range.scale.x = dir
		hitbox.scale.x = dir
		hurtbox.scale.x = dir
		collision.position.x = -1

func anims() -> void:
	if is_attacking: return
	elif is_hurting:
		animater.play(slime_color + " hurt")
	elif is_walking:
		animater.play(slime_color + " walk")

func player_in_range(body: Node2D) -> void:
	if body is Player:
		is_chasing = true
		is_wandering = false

func player_not_in_range(body: Node2D) -> void:
	if body is Player:
		is_chasing = false
		await get_tree().create_timer(0.75).timeout
		dir = -dir
		is_wandering = true

func attack(body: Node2D) -> void:
	if body is Player:
		is_attacking = true
		while is_attacking:
			animater.play(slime_color + " attack")
			await get_tree().create_timer(0.2).timeout
			hit_collision.disabled = false
			await get_tree().create_timer(0.6).timeout
			hit_collision.disabled = true
			await get_tree().create_timer(0.2).timeout
			await get_tree().create_timer(1).timeout

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
		await get_tree().create_timer(0.5).timeout
		is_hurting = false

func player_hurt_entered(area: Area2D) -> void:
	if area.get_parent() is Player and player:
		print("here")
		player.health_change(-20)
