extends CharacterBody2D
var dashing := false
var dash_timer := 0.0
var cooldown_timer := 0.0
var dash_dir := Vector2.RIGHT
var dash_hit_window := 0.0
var dash_hit_list := []
@onready var ink_overlay: TextureRect = $InkLayer/InkSplatter
@export var speed := 235
@export var dash_speed := speed*2
@export var dash_time := 0.03
@export var dash_cooldown := 1.5
@export var base_damage := 20.0
@export var acceleration := 4.0
@export var drag := 2.0
@export var turn_speed := 3.0   # radians/sec when turning
@export var maxstamina: int = 100
@export var boostmult: float = 1.4
@export var animplaymult: float = 1.0
@export var anim_speed := 0.5
@export var regen_delay := 5.0
@export var regen_amt := 0.08
@export var shallow_scale := 50.0
@export var deep_scale := 4.0
@export var shallow_x := -16.0
@export var deep_x := 384.0
@export var shallow_speed_mult := 1.05
@export var deep_speed_mult := 0.85
var since_hit := 999.0
var stamina: float = maxstamina
@onready var sprite: Node2D = $Sprite2D
@onready var healthbar: ProgressBar = $healthbar
@onready var xpbar: ProgressBar = $xpbar
@onready var light: PointLight2D = $PointLight2D
var animtimer: float = 0.15
@onready var levelup_fx: AnimatedSprite2D = $levelup
@export var visibility := 1.0
func play_levelup():
	levelup_fx.visible = true
	levelup_fx.frame = 0
	levelup_fx.play("default")
func _ready():
	levelup_fx.top_level = true
	levelup_fx.visible = false
	levelup_fx.animation_finished.connect(func(): levelup_fx.visible = false)

func _physics_process(delta):
	levelup_fx.global_position = global_position
	if healthbar.health <= 0.0:
		healthbar.health = healthbar.max_health
		xpbar.death()
		global_position = Vector2(0, 0)
		healthbar.update_bar()
	since_hit += delta
	if since_hit >= regen_delay and healthbar.health < healthbar.max_health:
		healthbar.heal(healthbar.max_health * regen_amt * delta)
	var tx = global_position.x / 32.0
	var lt = clamp((tx - shallow_x) / (deep_x - shallow_x), 0.0, 1.0)
	var target_scale = lerp(shallow_scale, deep_scale, lt)
	light.texture_scale = lerp(light.texture_scale, target_scale * visibility, delta * 3.0)
	var speed_mult = lerp(shallow_speed_mult, deep_speed_mult, lt)
	cooldown_timer = max(cooldown_timer - delta, 0.0)
	dash_hit_window = max(dash_hit_window - delta, 0.0)
	if dash_hit_window > 0.0:
		var bodies = $DashHitbox.get_overlapping_bodies().filter(
			func(b): return b.is_in_group("enemy") and b.has_method("hit") and not dash_hit_list.has(b))
		bodies.sort_custom(func(a, b):
			return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position))
		for body in bodies:
			var mult = max(1.0 - dash_hit_list.size() * 0.2, 0.0)
			if mult <= 0.0:
				break
			body.hit(base_damage * mult)
			dash_hit_list.append(body)
	if dashing:
		dash_timer -= delta
		velocity = dash_dir * dash_speed * speed_mult
		move_and_slide()
		if dash_timer <= 0.0:
			dashing = false
		return
	if Input.is_action_just_pressed("dash") and cooldown_timer <= 0.0:
		dashing = true
		dash_timer = dash_time
		dash_hit_window = 0.2
		cooldown_timer = dash_cooldown
		dash_hit_list.clear()
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
		velocity = velocity.lerp(forward * speed * speed_mult * thrust, acceleration * delta)
		animplaymult = max(velocity.length()/speed, 1)
		$AnimatedSprite2D.speed_scale = animplaymult * anim_speed
		$AnimatedSprite2D.play("swim")
	elif turn != 0:
		animtimer = 0.15
		velocity = velocity.lerp(forward * rotforwardspeed * speed_mult, acceleration * delta * 0.6)
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
func ink_splatter():
	ink_overlay.rotation = randf_range(0, TAU)
	ink_overlay.scale.x = 1.0 if randf() < 0.5 else -1.0
	ink_overlay.scale.y = 1.0 if randf() < 0.5 else -1.0
	ink_overlay.modulate.a = 1.0
	var tw = create_tween()
	tw.tween_property(ink_overlay, "modulate:a", 0.0, 3.0)
