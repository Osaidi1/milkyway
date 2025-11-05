extends CanvasLayer

@onready var health_bar: ProgressBar = $Container/Bars/Health
@onready var health_backlay: ProgressBar = $Container/Bars/HealthBacklay
@onready var stamina_bar: ProgressBar = $Container/Bars/Stamina
@onready var stamina_regen_wait: Timer = $Container/Bars/StaminaRegenWait

@export var player: CharacterBody2D

func health_change(new_health):
	health_bar.value = new_health
	await get_tree().create_timer(1.5).timeout
	while health_backlay.value > health_bar.value:
		health_backlay.value -= 1
		await get_tree().process_frame

func _process(delta: float) -> void:
	if player.is_in_wall:
		stamina_bar.value -= 5 * delta
	if stamina_regen_wait.is_stopped() and !stamina_bar.value == 100:
		stamina_regen_wait.start()

func _on_stamina_regen_wait_timeout() -> void:
	stamina_bar.value += 0.075
