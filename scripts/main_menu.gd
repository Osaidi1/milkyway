extends Control

const LEVEL_1 = preload("res://levels/level_1.tscn") as PackedScene

func _on_new_game_pressed() -> void:
	transition.to_black()
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_packed(LEVEL_1)
	transition.to_normal()
