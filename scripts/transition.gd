extends CanvasLayer

@onready var change: AnimationPlayer = $change
@onready var black: ColorRect = $Black

func _ready() -> void:
	black.visible = false

func to_black() -> void:
	black.visible = true
	change.play("to_black")

func to_normal() -> void:
	change.play("to_normal")
	await get_tree().create_timer(0.5).timeout
	black.visible = false
