extends Area2D

@onready var cutscenes: AnimationPlayer = $"../Cutscenes"

@onready var texts: AnimationPlayer = $texts

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		transition.to_black()
		await get_tree().create_timer(2).timeout
		texts.play("fin")
		await get_tree().create_timer(20).timeout
		get_tree().change_scene_to_file("res://ui/main_menu.tscn")
		transition.to_normal()
