extends Area2D

@export var wait := 1.0

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		await get_tree().create_timer(wait / 2).timeout
		transition.to_black()
		await get_tree().create_timer(1.3).timeout
		get_tree().reload_current_scene()
		transition.to_normal()
