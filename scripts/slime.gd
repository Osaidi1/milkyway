class_name Slime
extends CharacterBody2D

@onready var animater: AnimatedSprite2D = $Animater
@onready var turn: RayCast2D = $Animater/Turn
@onready var attack_range: Area2D = $AttackRange
@onready var hit_collision: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var hurtbox: Area2D = $Hurtbox
@onready var hitbox: Area2D = $Hitbox
@onready var collision: CollisionShape2D = $Collision
@onready var hurt: AnimationPlayer = $hurt

@export var HEALTH := 60
@export var SPEED := 30
@export var JUMP_VELOCITY := -250
@export var player: CharacterBody2D

@export_enum("red", "orange", "yellow", "green", "blue", "peach", "gray", "pink") 
var slime_color: String
var KNOCKBACK: Vector2 = Vector2.ZERO

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
var is_dying := false
var knockback_timer := 0.0

func _ready() -> void:
	hit_collision.disabled = true

func _physics_process(delta: float) -> void:
	#Nothing if Dead
	if is_dying: return
	
	#Die if no Health
	if HEALTH <= 0:
		die()
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Knockback
	if knockback_timer > 0.0:
		velocity = KNOCKBACK
		knockback_timer -= delta
		if knockback_timer <= 0.0:
			KNOCKBACK = Vector2.ZERO
		move_and_slide()
		return
	
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
			velocity.x = SPEED * dir
	
	#Call Funcs
	facing_dir()
	
	health_set()
	
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
	if body is Player and !is_attacking:
		is_attacking = true
		animater.play(slime_color + " attack")
		await get_tree().create_timer(0.4).timeout
		hit_collision.disabled = false
		await get_tree().create_timer(0.25).timeout
		hit_collision.disabled = true
		await get_tree().create_timer(0.35).timeout
		await get_tree().create_timer(0.5).timeout
		while velocity.y != 0 :
			await get_tree().create_timer(0.1).timeout
		is_attacking = false

func attack_exit(body: Node2D) -> void:
	if body is Player:
		is_chasing = true

func die() -> void:
	is_dying = true
	animater.play(slime_color + " die")
	collision.disabled = true
	velocity.y = 0
	await get_tree().create_timer(1).timeout
	queue_free()

func health_set() -> void:
	HEALTH = clamp(HEALTH, 0, 100)

func health_change(diff) -> void:
	var prev_health = HEALTH
	HEALTH += diff
	if prev_health > HEALTH:
		is_hurting = true
		hurt.play("hurt")
		await get_tree().create_timer(0.5).timeout
		is_hurting = false

func player_hurt_entered(area: Area2D) -> void:
	if area.get_parent() is Player and player and !is_hurting:
		player.health_change(-10)
		var knockback_direction = (area.global_position - global_position).normalized()
		player.apply_knockback(knockback_direction, 150, 0.2)

func apply_knockback(direction_for_knock: Vector2, force: float, knockback_duration: float) -> void:
	KNOCKBACK = direction_for_knock * force
	KNOCKBACK.y *= 0
	knockback_timer = knockback_duration
