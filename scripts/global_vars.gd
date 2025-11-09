extends Node

@export var dash_unlocked := false
@export var dash_stamina := true
@export var wall_slide_jump_unlocked := false
@export var wall_slide_jump_stamina := true
@export var attack_unlocked := false
@export var attack_2_unlocked := false
@export var attack_3_unlocked := true
@export var attack_stamina := true

var in_water: bool

var player_spawn := Vector2(-134, 658)
var player_spawn_2 := Vector2(-198, -2997)

var checkpoints = {}

func activate_checkpoint(id):
	checkpoints[id] = true

func is_checkpoint_active(id) -> int:
	return checkpoints.get(id, false)
