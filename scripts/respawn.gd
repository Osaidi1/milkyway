extends Node2D

@export var Number: int
var has_been_turned_on := false

@onready var spawn: Marker2D = $Spawn
@onready var collision: CollisionShape2D = $Check/Collision

func _ready():
	if vars.is_checkpoint_active(Number):
		collision.queue_free()

func _on_check_body_entered(body: Node2D) -> void:
	if body is Player:
		collision.queue_free()
		vars.activate_checkpoint(Number)
		if $"../../Go To Next Level".level == 1:
			vars.player_spawn = spawn.global_position
		elif $"../../Go To Next Level".level == 2:
			vars.player_spawn_2 = spawn.global_position

func activate_visuals():
	collision.queue_free()
