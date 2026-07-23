extends CharacterBody2D

@export var speed := 235
@export var acceleration := 4.0
@export var drag := 2.0
@export var turn_speed := 3.0   # radians/sec when turning
@export var maxstamina: int = 100
@export var boostmult: float = 1.4
@export var animplaymult: float = 1.0
@export var anim_speed := 0.5
var stamina: float = maxstamina
@onready var sprite: Node2D = $Sprite2D
@onready var staminabar: ProgressBar = $ProgressBar
var animtimer: float = 0.15
func _ready() -> void:
	staminabar.position = Vector2(-13, -25)
func _physics_process(delta):
	var boosting: bool = false
	# turning
	#added forward momentum when rotation for realism
	var turn = Input.get_axis("left", "right")
	rotation += turn * turn_speed * delta
	# go in the curr direction
	var rotforwardspeed = speed * 0.8
	var forward = Vector2.RIGHT.rotated(rotation)
	# fwd/bkwd
	var thrust = max(Input.get_axis("backward", "forward"), 0.0)	
	if thrust != 0:
		animtimer = 0.15
		if Input.is_key_pressed(KEY_SHIFT) and stamina > 0:
			stamina -= 20 * delta
			velocity = velocity.lerp(forward * speed * thrust * boostmult, acceleration * delta * boostmult)
			boosting = true
		else:
			velocity = velocity.lerp(forward * speed * thrust, acceleration * delta)
			boosting = false
		animplaymult = max(velocity.length()/speed, 1)
		$AnimatedSprite2D.speed_scale = animplaymult * anim_speed
		$AnimatedSprite2D.play("swim")
	elif turn != 0:
		animtimer = 0.15
		velocity = velocity.lerp(forward * rotforwardspeed, acceleration * delta * 0.6)
		animplaymult = velocity.length() / speed
		$AnimatedSprite2D.speed_scale = max(animplaymult, 0.4) * anim_speed
		$AnimatedSprite2D.play("swim")
		boosting = false
	else:
		# MAKES ANIM ONLY STOP WHEN ON FRAME 1 ELSE LOOKS FUNNY
		if $AnimatedSprite2D.frame == 1 or $AnimatedSprite2D.frame == 3:
			$AnimatedSprite2D.speed_scale = 0.0
			animtimer -= delta
			if animtimer <= 0:
				$AnimatedSprite2D.stop()
		else:
			$AnimatedSprite2D.speed_scale = 0.78 * anim_speed
		velocity = velocity.lerp(Vector2.ZERO, drag * delta)
		boosting = false
	if not $AnimatedSprite2D.is_playing():
		$AnimatedSprite2D.play("idle")
	if velocity.length() > 150:
		var rotweight = log(velocity.length())/(log(12) * 26)
		rotation = lerp_angle(rotation, velocity.angle(), rotweight)
	stamina = clamp(stamina, 0, maxstamina)
	if boosting == false:
		stamina += 8 * delta
	staminabar.value = stamina
	move_and_slide()
