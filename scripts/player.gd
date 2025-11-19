class_name Player
extends CharacterBody2D

@onready var animater: AnimatedSprite2D = $Animater
@onready var collision: CollisionShape2D = $Collision
@onready var camera: Camera2D = $Camera
@onready var coyote: Timer = $coyote
@onready var side: RayCast2D = $Animater/side
@onready var side2: RayCast2D = $Animater/side2
@onready var combo_timer: Timer = $combo
@onready var cooldown: Timer = $cooldown
@onready var jump_buffer: Timer = $"jump buffer"
@onready var cutscenes: AnimationPlayer = $"../Cutscenes"
@onready var sword_sound_2: AudioStreamPlayer2D = $SwordSound2
@onready var hurtbox: Area2D = $Hurtbox
@onready var hitbox: Area2D = $Hitbox
@onready var hit_collision: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var hurt_screen: CanvasLayer = $"Red Hurtscreen/Hurt Screen"
@onready var dash_tutorial: RichTextLabel = $"Dash Tutorial"
@onready var wall_tutorial: RichTextLabel = $"Wall Tutorial"
@onready var attack_tutorial: RichTextLabel = $"Attack Tutorial"

@export var WALK_SPEED := 55
@export var RUN_SPEED := 145
@export var DASH_SPEED := 500
@export var JUMP_VELOCITY : = -400
@export var HEALTH := 100
@export var SLIDE_FRICTION := 40
@export var WALL_JUMP_POWER := 100
@export var SMOOTH_ENABLE_TIME := 2.0
@export var CAN_CONTROL := true
@export var BARS: CanvasLayer

enum attack_state {Att1, Att2, Att3}
var rng = RandomNumberGenerator.new()
var KNOCKBACK : Vector2 = Vector2.ZERO

var speed: int
var direction: float
var is_jumping := false
var is_falling := false
var is_attacking := false
var is_dashing := false
var is_dying := false
var is_hurting := false
var is_in_wall := false
var is_wall_jumping := false
var is_hanging := false
var fall_start_played := false
var was_on_floor := false
var dash_time: float
var dash_duration := 0.35
var looking_toward := 1
var wall_jump_lock := 0.0
var wall_jump_lock_time := 0.2
var wall_stay := 0.0
var wall_stay_time := 0.05
var knockback_timer := 0.0
var att_state := 1
var last_delta := 0.0
var can_attack := true

func _ready() -> void:
	camera.position_smoothing_enabled = false
	global_position = vars.player_spawn
	if vars.player_spawn == Vector2(-134, 658):
		cutscenes.play("intro")
	else:
		cutscenes.play("RESET")
	hit_collision.disabled = true
	is_dying = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	await get_tree().create_timer(0.01).timeout
	camera.position_smoothing_enabled = true

func _unhandled_input(event: InputEvent) -> void:
	#Can't Control
	if !CAN_CONTROL: return
	
	#Dash
	if Input.is_action_just_pressed("dash") and !is_attacking and !is_dying and !is_hurting and !is_in_wall and !is_dashing and vars.dash_unlocked and BARS.stamina_bar.value > 40:
		dash()
	
	#Jump
	if is_on_floor() or !coyote.is_stopped() or is_in_wall:
		if event.is_action_pressed("jump") and !is_attacking and !is_dying and !is_hurting and !is_jumping and BARS.stamina_bar.value > 5:
			jump()
	
	#Attack
	if event.is_action_released("attack") and !is_jumping and !is_falling and !is_dying and !is_hurting and !is_in_wall and can_attack and vars.attack_unlocked and BARS.stamina_bar.value > 30:
		attack()

func _physics_process(delta: float) -> void:
	last_delta = delta
	
	#Can't Control
	if !CAN_CONTROL: return
	
	#Dying
	if is_dying: return
	
	#In Water
	if vars.in_water:
		z_index = -5
		velocity.y = velocity.y / 1.2
	else:
		z_index = 1
	
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
	
	#Knockback
	if knockback_timer > 0.0:
		velocity = KNOCKBACK
		knockback_timer -= delta
		if knockback_timer <= 0.0:
			KNOCKBACK = Vector2.ZERO
	
	#Falling
	if !Input.is_action_just_pressed("jump") and velocity.y > 0:
		is_falling = true
		velocity.y *= 1.02
	
	#Jump Buffer
	if Input.is_action_pressed("jump"):
		jump_buffer.start()
	if is_on_floor() and !jump_buffer.is_stopped():
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
			if !is_dashing or !is_wall_jumping or !vars.in_water:
				velocity.x = direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
	
	#Movement in Water
	if vars.in_water:
		velocity.x = velocity.x / 8
	
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

func speed_set() -> void:
	if Input.is_action_pressed("run"):
		speed = RUN_SPEED
	else:
		speed = WALK_SPEED

func face_direction() -> void:
	if is_in_wall: return
	if direction < 0 or (is_in_wall and (Input.is_action_just_pressed("jump") or is_on_floor())):
		animater.flip_h = true
		looking_toward = -1
		side.target_position = Vector2(-6.5, 0)
		side2.target_position = Vector2(-6.5, 0)
		hurtbox.scale.x = -1
		hitbox.scale.x = -1
	elif direction > 0 or (is_in_wall and (Input.is_action_just_pressed("jump") or is_on_floor())):
		animater.flip_h = false
		looking_toward = 1
		side.target_position = Vector2(6.5, 0)
		side2.target_position = Vector2(6.5, 0)
		hurtbox.scale.x = 1
		hitbox.scale.x = 1

func anims() -> void:
	#Can't Control
	if !CAN_CONTROL: return
	
	if is_dying or is_hurting or is_attacking: return
	if is_dashing:
		animater.play("dash")
	elif is_in_wall:
		animater.play("wall slide")
	elif is_wall_jumping:
		animater.play("wall jump")
		await get_tree().create_timer(0.49).timeout
		is_wall_jumping = false
	elif is_jumping or velocity.y < 0:
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

func attack() -> void:
	if is_attacking: return
	if att_state == 1:
		is_attacking = true
		animater.play("attack 1")
		hit_collision.disabled = false
		await get_tree().create_timer(0.27).timeout
		hit_collision.disabled = true
		animater.play("attack 1 recover")
		await get_tree().create_timer(0.443).timeout
		is_attacking = false
		can_attack = false
		cooldown.start()
		if vars.attack_2_unlocked:
			combo_timer.start()
			att_state = 2
		else:
			att_state = 1
	elif att_state == 2:
		is_attacking = true
		animater.play("attack 2")
		sword_sound_2.pitch_scale = rng.randf_range(0.9, 1.2)
		sword_sound_2.play()
		await get_tree().create_timer(0.25).timeout
		hit_collision.disabled = false
		await get_tree().create_timer(0.25).timeout
		hit_collision.disabled = true
		animater.play("attack 2 recover")
		await get_tree().create_timer(0.44).timeout
		is_attacking = false
		can_attack = false
		cooldown.start()
		if vars.attack_3_unlocked:
			combo_timer.start()
			att_state = 3
		else:
			att_state = 1
	elif att_state == 3:
		is_attacking = true
		animater.play("attack 3")
		await get_tree().create_timer(0.272727).timeout
		hit_collision.disabled = false
		await get_tree().create_timer(0.727272).timeout
		hit_collision.disabled = true
		animater.play("attack 3 recover")
		await get_tree().create_timer(0.5).timeout
		is_attacking = false
		can_attack = false
		combo_timer.start()
		cooldown.start()
		att_state = 1

func jump() -> void:
	if is_attacking: return
	is_jumping = true
	velocity.y = JUMP_VELOCITY
	if is_in_wall:
		velocity.x = WALL_JUMP_POWER * -looking_toward
		is_wall_jumping = true
		is_in_wall = false
		wall_jump_lock = wall_jump_lock_time

func health_set() -> void:
	HEALTH = clamp(HEALTH, 0, 100)

func health_change(diff) -> void:
	if is_dying: return
	var prev_health = HEALTH
	HEALTH += diff
	BARS.health_change(HEALTH)
	if HEALTH < 20:
		hurt_screen.visible = true
	else:
		hurt_screen.visible = false
	if prev_health > HEALTH and !cutscenes.is_playing():
		is_hurting = true
		animater.play("hurt")
		velocity.x = -looking_toward * 30
		await get_tree().create_timer(0.624).timeout
		is_hurting = false

func die() -> void:
	is_dying = true
	animater.play("hurt")
	await get_tree().create_timer(0.625).timeout
	animater.play("death")
	collision.disabled = true
	velocity.y = 0
	await get_tree().create_timer(3).timeout
	transition.to_black()
	await get_tree().create_timer(1).timeout
	transition.to_normal()
	reload()

func dash() -> void:
	is_dashing = true
	dash_time = 0.0

func in_void(body: Node2D) -> void:
	if body is Player:
		await get_tree().create_timer(1).timeout
		get_tree().reload_current_scene()

func wall_logic() -> void:
	if side.is_colliding() and side2.is_colliding() and !is_on_floor() and velocity.y > 0 and vars.wall_slide_jump_unlocked and BARS.stamina_bar.value >= 5:
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

func _on_danger_body_entered(body: Node2D) -> void:
	if body is Player:
		await get_tree().create_timer(1).timeout
		reload()

func reload() -> void:
	await get_tree().create_timer(3).timeout
	get_tree().reload_current_scene()

func enemy_hurt_entered(area: Area2D) -> void:
	if area.get_parent() is Slime:
		var knockback_direction = (area.global_position - global_position).normalized()
		if att_state == 1:
			area.get_parent().health_change(-20)
			area.get_parent().apply_knockback(knockback_direction, 150, 0.2)
		if att_state == 2:
			area.get_parent().health_change(-30)
			area.get_parent().apply_knockback(knockback_direction, 175, 0.25)
		if att_state == 3:
			area.get_parent().health_change(-50)
			area.get_parent().apply_knockback(knockback_direction, 200, 0.3)

func enemy_hit_entered(_area: Area2D) -> void:
	health_change(-20)

func apply_knockback(direction_for_knock: Vector2, force: float, knockback_duration: float) -> void:
	KNOCKBACK = direction_for_knock * force
	KNOCKBACK.y *= 0
	knockback_timer = knockback_duration

func _enable_camera_smooth() -> void:
	camera.position_smoothing_enabled = true

func play_anim(anim_name: String) -> void:
	animater.play(anim_name)

func play_wall_jump() -> void:
	animater.play("wall jump")

func _on_dash_unlock_body_entered(body: Node2D) -> void:
	if body is Player:
		vars.dash_unlocked = true
		for i in range(15):
			dash_tutorial.visible_characters += 1
			await get_tree().create_timer(0.05).timeout
		await get_tree().create_timer(2).timeout
		for i in range(15):
			dash_tutorial.visible_characters -= 1
			await get_tree().create_timer(0.05).timeout
		$"../DashUnlock/CollisionShape2D".queue_free()

func _on_wall_unlock_body_entered(body: Node2D) -> void:
	if body is Player:
		vars.wall_slide_jump_unlocked = true
		for i in range(29):
			wall_tutorial.visible_characters += 1
			await get_tree().create_timer(0.02).timeout
		await get_tree().create_timer(3).timeout
		for i in range(29):
			wall_tutorial.visible_characters -= 1
			await get_tree().create_timer(0.02).timeout
		$"../DashUnlock/CollisionShape2D".queue_free()

func _on_attack_unlock_body_entered(body: Node2D) -> void:
	if body is Player:
		vars.attack_unlocked = true
		for i in range(30):
			attack_tutorial.visible_characters += 1
			await get_tree().create_timer(0.02).timeout
		await get_tree().create_timer(3).timeout
		for i in range(30):
			attack_tutorial.visible_characters -= 1
			await get_tree().create_timer(0.02).timeout
		$"../DashUnlock/CollisionShape2D".queue_free()
