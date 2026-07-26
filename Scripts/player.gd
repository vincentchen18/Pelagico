extends CharacterBody2D

var dashing := false
var dash_timer := 0.0
var cooldown_timer := 0.0
var dash_dir := Vector2.RIGHT
@export var speed := 235
@export var dash_speed := speed*2
@export var dash_time := 0.03
@export var dash_cooldown := 1.5
@export var acceleration := 4.0
@export var drag := 2.0
@export var turn_speed := 3.0   # radians/sec when turning
@export var maxstamina: int = 100
@export var boostmult: float = 1.4
@export var animplaymult: float = 1.0
@export var anim_speed := 0.5
@export var regen_delay := 5.0
@export var regen_amt := 0.08
var since_hit := 999.0
var stamina: float = maxstamina
@onready var sprite: Node2D = $Sprite2D
@onready var healthbar: ProgressBar = $healthbar
var animtimer: float = 0.15
func _physics_process(delta):
	since_hit += delta
	if since_hit >= regen_delay and healthbar.health < healthbar.max_health:
		healthbar.heal(healthbar.max_health * regen_amt * delta)
	cooldown_timer = max(cooldown_timer - delta, 0.0)

	if dashing:
		dash_timer -= delta
		velocity = dash_dir * dash_speed
		move_and_slide()
		if dash_timer <= 0.0:
			dashing = false
		return

	if Input.is_action_just_pressed("dash") and cooldown_timer <= 0.0:
		dashing = true
		dash_timer = dash_time
		cooldown_timer = dash_cooldown
		dash_dir = Vector2.RIGHT.rotated(rotation)
	var boosting: bool = false
	# turning
	#added forward momentum when rotation for realism
	var turn = Input.get_axis("left", "right")
	rotation += turn * turn_speed * delta
	# go in the curr direction
	var rotforwardspeed = speed * 0.8
	var forward = Vector2.RIGHT.rotated(rotation)
	# fwd/bkwd
	var thrust = 0
	if Input.is_action_pressed("forward"):
		thrust += 1.0
	elif Input.is_action_pressed("backward"):
		thrust -= 0.2
	if thrust != 0:
		animtimer = 0.15
		velocity = velocity.lerp(forward * speed * thrust, acceleration * delta)

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

	move_and_slide()
func hit(amount):
	healthbar.take_damage(amount)
	since_hit = 0.0
