extends Area2D

@onready var fin: Label = $"../Text/Fin"
@onready var at_least_for_now: Label = $"../Text/at least for now"
@onready var credits: Label = $"../Text/Credits"
@onready var bye: Label = $"../Text/Bye"

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		transition.to_black()
		await get_tree().create_timer(2).timeout
		#Fin
		
		for i in range(3):
			fin.visible_characters += 1
			await get_tree().create_timer(0.05).timeout
		await get_tree().create_timer(3).timeout
		for i in range(3):
			fin.visible_characters -= 1
			await get_tree().create_timer(0.05).timeout
		await get_tree().create_timer(2).timeout
		
		# at least for now
		
		for i in range(18):
			at_least_for_now.visible_characters += 1
			await get_tree().create_timer(0.02).timeout
		await get_tree().create_timer(4).timeout
		for i in range(18):
			at_least_for_now.visible_characters -= 1
			await get_tree().create_timer(0.02).timeout
		await get_tree().create_timer(2).timeout
		
		#Credits
		
		for i in range(217):
			credits.visible_characters += 1
			await get_tree().create_timer(0.02).timeout
		await get_tree().create_timer(5).timeout
		for i in range(217):
			credits.visible_characters -= 1
			await get_tree().create_timer(0.02).timeout
		await get_tree().create_timer(2).timeout
		
		#Bye
		
		for i in range(3):
			bye.visible_characters += 1
			await get_tree().create_timer(0.05).timeout
		await get_tree().create_timer(3).timeout
		for i in range(3):
			bye.visible_characters -= 1
			await get_tree().create_timer(0.05).timeout
		await get_tree().create_timer(2).timeout
		
		# End
		
		get_tree().change_scene_to_file("res://ui/main_menu.tscn")
		transition.to_normal()
