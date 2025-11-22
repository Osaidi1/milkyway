extends Sprite2D

func _on_danger_body_entered(body: Node2D) -> void:
	if body is Player:
		body.is_dying = true
