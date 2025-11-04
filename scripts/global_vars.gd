extends Node

@export var dash_unlocked := true
@export var wall_slide_jump_unlocked := false
@export var attack_unlocked := true
@export var attack_2_unlocked := false
@export var attack_3_unlocked := false

var in_water: bool

var player_spawn := Vector2(-158, 635)
var checkpoints = {}

func activate_checkpoint(id):
	checkpoints[id] = true

func is_checkpoint_active(id):
	return checkpoints.get(id, false)
