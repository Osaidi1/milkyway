extends Node

@export var dash_unlocked := false
@export var dash_stamina := false
@export var wall_slide_jump_unlocked := true
@export var wall_slide_jump_stamina := true
@export var attack_unlocked := false
@export var attack_2_unlocked := false
@export var attack_3_unlocked := true
@export var attack_stamina := true

var in_water: bool
var level := 1

var player_spawn := Vector2(-135, 658)

var checkpoints = {}

func activate_checkpoint(id):
	checkpoints[id] = true

func is_checkpoint_active(id) -> int:
	return checkpoints.get(id, false)
