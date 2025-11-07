extends CanvasLayer

@onready var health_bar: ProgressBar = $Container/Bars/Health
@onready var health_backlay: ProgressBar = $Container/Bars/HealthBacklay
@onready var stamina_bar: ProgressBar = $Container/Bars/Stamina
@onready var stamina_regen_wait: Timer = $Container/Bars/StaminaRegenWait

@export var player: CharacterBody2D

var regen_waited := false
var is_regening := false
var attack_stamina_taken := false
var dash_stamina_taken := false

func health_change(new_health):
	health_bar.value = new_health
	await get_tree().create_timer(0.5).timeout
	while health_backlay.value > health_bar.value:
		health_backlay.value -= 1
		await get_tree().create_timer(0.01).timeout

func _process(delta: float) -> void:
	if player.is_in_wall and vars.wall_slide_jump_stamina:
		stamina_bar.value -= 5 * delta
		stamina_bar.value = clamp(stamina_bar.value, 0, 100)
		if !stamina_regen_wait.is_stopped():
			stamina_regen_wait.stop()
		regen_waited = false
	if player.is_attacking and !attack_stamina_taken and vars.attack_stamina:
		match player.att_state:
			1:
				stamina_bar.value -= 10
			2:
				stamina_bar.value -= 20
			3:
				stamina_bar.value -= 30
		attack_stamina_taken = true
		stamina_bar.value = clamp(stamina_bar.value, 0, 100)
		is_regening = false
		regen_waited = false
	if player.is_attacking == false:
		attack_stamina_taken = false
	if player.is_dashing and !dash_stamina_taken and vars.dash_stamina:
		stamina_bar.value -= 25
		stamina_bar.value = clamp(stamina_bar.value, 0, 100)
		dash_stamina_taken = true
		is_regening = false
		regen_waited = false
	if player.is_dashing == false:
		dash_stamina_taken = false
	if stamina_regen_wait.is_stopped() and stamina_bar.value < 100 and !regen_waited and !player.is_in_wall:
		stamina_regen_wait.start()
		regen_waited = true
	if is_regening:
		stamina_bar.value += 15 * delta
		stamina_bar.value = clamp(stamina_bar.value, 0, 100)
		if stamina_bar.value >= 100:
			is_regening = false
			regen_waited = false

func _on_stamina_regen_wait_timeout() -> void:
	is_regening = true
