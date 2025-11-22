extends Control

const LEVEL_1 = preload("res://levels/level_1.tscn") as PackedScene

@onready var new_game: Button = $"New Game"
@onready var load_game: Button = $"Load Game"
@onready var quit: Button = $Quit

func _ready() -> void:
	new_game.grab_focus()
	load_game.disabled = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_new_game_pressed() -> void:
	transition.to_black()
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_packed(LEVEL_1)
	transition.to_normal()

func _on_quit_pressed() -> void:
	transition.to_black()
	await get_tree().create_timer(1.5).timeout
	get_tree().quit()
