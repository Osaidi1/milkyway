extends Area2D

@export var level: int

const LEVEL_2 = preload("res://levels/level_2.tscn") as PackedScene

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if level == 1:
			transition.to_black()
			await get_tree().create_timer(1.5).timeout
			transition.to_normal()
			get_tree().change_scene_to_packed(LEVEL_2)
