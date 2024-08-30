extends RigidBody3D

const FRICTION:float = 1.0
const ACCELERATION:float = 10.0
const BRAKE_POWER:float = 200.0
const TURN_FORCE:float = 500.0

@export var max_forward_speed:float = 200.0
@export var max_turn_radius:float = 0.6

@onready var camera_3d: Camera3D = %Camera3D
@onready var turn_point: Marker3D = %turn_point

var speed :float = 10.0
var direction:Vector3 = Vector3.ZERO

var current_speed:float = 0.0:
	set(_value):
		current_speed = _value
		S.SpeedUpdate.emit(current_speed)
var max_reverse_speed:float = max_forward_speed/4
var accelerating:bool = false
var braking:bool = false
var reversing:bool = false
var turn:float = 0.0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("forward"):
		accelerating = true
	elif event.is_action_released("forward"):
		accelerating = false
	
	if event.is_action_pressed("back"):
		reversing = true
	elif event.is_action_released("back"):
		reversing = false
		
	

func _physics_process(_delta: float) -> void:
	# TODO: Add grounding
	
	turn = Input.get_axis("left", "right")
	
	var direction = basis * Vector3.FORWARD
	
	var is_reversing: bool = false 
	if accelerating and !reversing: is_reversing = false
	elif !accelerating and reversing: is_reversing = true
	
	if accelerating or reversing: _propulsion(is_reversing, _delta)
	
	var force = direction.z * current_speed
	
	if !accelerating and !braking and !reversing: 
		current_speed = move_toward(current_speed, 0, _delta * FRICTION)
		#velocity.z = move_toward(velocity.z, 0, _delta * FRICTION)
	
	apply_force(direction * current_speed)
	
	print(Vector3.DOWN * turn * TURN_FORCE * _delta)
	apply_torque(Vector3.DOWN * turn * TURN_FORCE * _delta)


func _propulsion(_is_reverse:bool, _delta:float) -> void:
	if !_is_reverse and current_speed >= 0.0:
		if braking: braking = false
		current_speed = move_toward(current_speed, max_forward_speed, _delta * ACCELERATION)
	elif _is_reverse and current_speed <= 0.0:
		if braking: braking = false
		current_speed = move_toward(current_speed, -max_forward_speed, _delta * ACCELERATION)
	elif (!_is_reverse and current_speed < 0.0) or(_is_reverse and current_speed > 0.0):
		braking = true
	
	if braking:
		current_speed = move_toward(current_speed, 0, _delta * ACCELERATION)
