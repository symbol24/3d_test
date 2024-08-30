extends VehicleBody3D

@export var STEER_SPEED = 1.5
@export var STEER_LIMIT = 0.6
var steer_target = 0
@export var engine_force_value = 60

@onready var camera_3d: Camera3D = %Camera3D

var direction:Vector3 = Vector3.ZERO

var current_speed:float = 0.0:
	set(_value):
		current_speed = _value
		S.SpeedUpdate.emit(current_speed)

func _physics_process(_delta: float) -> void:
	current_speed = linear_velocity.length() * Engine.get_frames_per_second() * _delta
	traction(current_speed)
	steer_target = Input.get_action_strength("left") - Input.get_action_strength("right")
	steer_target *= STEER_LIMIT
	
	var fwd_mps = transform.basis.x.x
	if Input.is_action_pressed("back"):
		if current_speed < 20 and current_speed != 0:
			engine_force = clamp(engine_force_value * 3 / current_speed, 0, 300)
		else:
			engine_force = engine_force_value
	else:
		engine_force = 0
	
	if Input.is_action_pressed("forward"):
		if fwd_mps >= -1:
			if current_speed < 30 and current_speed != 0:
				engine_force = -clamp(engine_force_value * 10 / current_speed, 0, 300)
			else:
				engine_force = -engine_force_value
		else:
			brake = 1
	else:
		brake = 0.0
	
	
	steering = move_toward(steering, steer_target, STEER_SPEED * _delta)

func traction(speed):
	apply_central_force(Vector3.DOWN*speed)
