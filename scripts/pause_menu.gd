extends Control

@onready var animater: AnimationPlayer = $Animater

const MAIN_MENU = preload("res://ui/main_menu.tscn")

func _ready() -> void:
	animater.play("RESET")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			resume()
		else:
			pause()

func resume() -> void:
	get_tree().paused = false
	animater.play_backwards("blur")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func pause() -> void:
	get_tree().paused = true
	animater.play("blur")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_resume_pressed() -> void:
	resume()

func _on_restart_pressed() -> void:
	resume()
	transition.to_black()
	await get_tree().create_timer(1.5).timeout
	get_tree().reload_current_scene()
	transition.to_normal()

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_packed(MAIN_MENU)

func _on_quit_pressed() -> void:
	get_tree().quit()
