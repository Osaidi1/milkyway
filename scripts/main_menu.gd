extends Control

const LEVEL_1 = preload("res://levels/level_1.tscn") as PackedScene

@onready var new_game: Button = $"New Game"
@onready var load_game: Button = $"Load Game"
@onready var quit: Button = $Quit
@onready var sound: AudioStreamPlayer = $"Sound Effect"

func _ready() -> void:
	sound.volume_db = -80
	new_game.grab_focus()
	load_game.disabled = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	await get_tree().create_timer(0.1).timeout
	sound.volume_db = 0

func _on_new_game_pressed() -> void:
	sound.play()
	transition.to_black()
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_packed(LEVEL_1)
	transition.to_normal()

func _on_quit_pressed() -> void:
	transition.to_black()
	sound.play()
	await get_tree().create_timer(1.5).timeout
	get_tree().quit()

func _on_new_game_focus_entered() -> void:
	sound.play()

func _on_quit_focus_entered() -> void:
	sound.play()
