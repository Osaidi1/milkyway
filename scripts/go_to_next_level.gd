extends Area2D

@onready var cutscenes: AnimationPlayer = $"../Cutscenes"

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		vars.level += 1
		transition.to_black()
		await get_tree().create_timer(5).timeout
		cutscenes.play("intro" + str(vars.level))
		transition.to_normal()
