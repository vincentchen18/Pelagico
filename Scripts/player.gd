extends CharacterBody2D

@export var speed := 300.0
@export var acceleration := 4.0
@export var drag := 2.0
@export var turn_speed := 3.0   # radians/sec when turning
@export var maxstamina: int = 100
@export var boostmult: float = 1.4
var stamina: float = maxstamina
@onready var sprite: Node2D = $Sprite2D
@onready var staminabar: ProgressBar = $ProgressBar
func _physics_process(delta):
	staminabar.position = Vector2(-13, -25)
	var boosting: bool = false
	# turning
	var turn = Input.get_axis("left", "right")
	rotation += turn * turn_speed * delta

	# fwd/bkwd
	var thrust = Input.get_axis("backward", "forward") 
	if thrust != 0:
		# go in the curr direction
		var forward = Vector2.RIGHT.rotated(rotation)
		if Input.is_key_pressed(KEY_SHIFT) and stamina > 0:
			stamina -= 20 * delta
			velocity = velocity.lerp(forward * speed * thrust * boostmult, acceleration * delta * boostmult)
			boosting = true
		else:
			velocity = velocity.lerp(forward * speed * thrust, acceleration * delta)
			boosting = false
	else:
		velocity = velocity.lerp(Vector2.ZERO, drag * delta)
		boosting = false
	stamina = clamp(stamina, 0, maxstamina)
	if boosting == false:
		stamina += 8 * delta
	staminabar.value = stamina
	move_and_slide()
