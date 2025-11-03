extends Area2D

@export var wait := 1.0

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		await get_tree().create_timer(wait).timeout
		get_tree().reload_current_scene()
