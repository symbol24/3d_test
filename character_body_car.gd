extends CharacterBody3D

const ACCELERATION :float = 10.0
const FRICTION: float = 2.0
const BRAKE_POWER: float = 50.0
const MAX_SPEED: = 200.0
const TURN_STRENGTH: float = 0.3
const DRIFT_BONUS: float = 0.2

@onready var ball: CollisionShape3D = %ball

@export var shift_rotation:float = 195
@export var drift_shift_rotation:float = 210

var current_speed:float = 0.0
var direction:Vector3
var shift: bool = false

func _physics_process(delta: float) -> void:
	direction = self.global_transform.basis.z
	
	if Input.is_action_pressed("forward"):
		if current_speed >= 0.0:
			current_speed = move_toward(current_speed, MAX_SPEED, delta * ACCELERATION)
		else:
			current_speed = move_toward(current_speed, 0, delta * BRAKE_POWER)
	elif Input.is_action_pressed("back"):
		if current_speed <= 0.0:
			current_speed = move_toward(current_speed, -(MAX_SPEED/4), delta * ACCELERATION)
		else:
			current_speed = move_toward(current_speed, 0, delta * BRAKE_POWER)
	else:
			current_speed = move_toward(current_speed, 0, delta * FRICTION)
	
	var drift:bool = false
	if Input.is_action_pressed("brake"):
		drift = true
		
	
	var turn_direction:float = Input.get_axis("left", "right")
	var is_left:bool = false if turn_direction <= 0.0 else true
	if turn_direction >= 0.33 or turn_direction <= -0.33: shift = true
	else: shift = false
	if current_speed >= 0.0: turn_direction = -turn_direction
	if current_speed < 0.0: is_left = !is_left
	if current_speed >= 33 and shift:
		_shift_car(is_left, ball, drift)
	elif current_speed >= 5 and drift:
		_shift_car(is_left, ball, drift)
	elif current_speed < 33 or !shift:
		_reset_shift(ball)
	
	var turn_stength:float = TURN_STRENGTH + DRIFT_BONUS if drift else TURN_STRENGTH
	rotate_y(turn_direction * delta * turn_stength)
	
	velocity = direction * -current_speed
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	move_and_slide()
	S.SpeedUpdate.emit(current_speed)

func _shift_car(_is_left:bool, _ball:CollisionShape3D, _is_drift:bool) -> void:
	var value = drift_shift_rotation if _is_drift else shift_rotation
	if _is_left:
		_ball.set_rotation(Vector3(0, -value, 0))
	else:
		_ball.set_rotation(Vector3(0, value, 0))
		
		
func _reset_shift(_ball:CollisionShape3D) -> void:
	_ball.set_rotation(Vector3(0, 0, 0))
