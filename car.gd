extends RigidBody3D

const FRICTION:float = 1.0
const ACCELERATION:float = 20.0
const BRAKE_POWER:float = 200.0
const TURN_FORCE:float = 500.0

@export var forward_impulse:float = 200.0
@export var max_speed:float = 70.0
@export var max_turn_radius:float = 0.6

@onready var camera_3d: Camera3D = %Camera3D
@onready var turn_point: Marker3D = %turn_point

var direction:Vector3 = Vector3.ZERO

var current_speed:float = 0.0
var max_reverse_speed:float = max_speed/2
var accelerating:bool = false
var braking:bool = false
var reversing:bool = false
var turn:float = 0.0
#
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("forward"):
		accelerating = true
	elif event.is_action_released("forward"):
		accelerating = false
	
	if event.is_action_pressed("back"):
		reversing = true
	elif event.is_action_released("back"):
		reversing = false
		
	if event.is_action_pressed("brake"):
		braking = true
	elif event.is_action_released("brake"):
		braking = false
		
	

func _physics_process(_delta: float) -> void:
	#downforce
	apply_force(Vector3.DOWN * (current_speed/10))
	
	turn = Input.get_axis("left", "right")
	
	direction = basis.z * Vector3.FORWARD
	
	var is_reversing: bool = false 
	if accelerating and !reversing: is_reversing = false
	elif !accelerating and reversing: is_reversing = true
	
	if accelerating and current_speed >= 0.0: 
		current_speed = move_toward(current_speed, forward_impulse, _delta * ACCELERATION)
		if linear_velocity.z > max_speed:
			apply_force(Vector3.FORWARD * current_speed)
	if reversing and current_speed <= 0.0: 
		current_speed = move_toward(current_speed, -forward_impulse, _delta * ACCELERATION)
		if linear_velocity.z < max_reverse_speed:
			apply_force(Vector3.FORWARD * current_speed)
	if braking:
		current_speed = move_toward(current_speed, 0, _delta * BRAKE_POWER)
		apply_force(Vector3.BACK * current_speed)
			
	
	apply_torque(Vector3.DOWN * turn * TURN_FORCE * _delta)
	
	S.SpeedUpdate.emit(-linear_velocity.z)
