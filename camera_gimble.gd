extends Node3D

const LOOKAROUND_SPEED = 100

@onready var parent:CharacterBody3D = get_parent() as CharacterBody3D
@onready var camera_3d: Camera3D = %Camera3D

var camera_yaw = 0.0
var camera_pitch = 0.0
var mouse_sensitivity = 0.001

func _input(event: InputEvent): 
	if event is InputEventMouseMotion: 
		camera_pitch += -event.relative.y * mouse_sensitivity
		camera_pitch = clamp(camera_pitch, -PI/2, PI/2) # Clamp to -90d to 90d
		camera_yaw += -event.relative.x * mouse_sensitivity 
		camera_yaw = fposmod(camera_yaw, TAU) # Wrap from 0d -> 180d (TAU)

func update_camera_rotation(delta): 
	const base = 0.5
	const exponent = 10.0
	var weight = pow(base, delta * exponent)
	weight = 1.0 - weight # Invert
	parent.rotation.y = lerp_angle(parent.rotation.y, camera_yaw, weight) 
	rotation.x = lerp_angle(rotation.x, camera_pitch, weight)
	
#func _process(delta): 
	#update_camera_rotation(delta)
