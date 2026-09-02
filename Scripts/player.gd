extends CharacterBody2D
var dashing := false
var dash_timer := 0.0
var cooldown_timer := 0.0
var dash_dir := Vector2.RIGHT
var dash_hit_window := 0.0
var dash_hit_list := []
var dash_start_pos := Vector2.ZERO
@onready var ink_overlay: TextureRect = $InkLayer/InkSplatter
@export var speed := 235
@export var dash_speed := speed*2
@export var dash_time := 0.08
@export var dash_cooldown := 1.5
@export var base_damage := 20.0
@export var acceleration := 4.0
@export var drag := 2.0
@export var turn_speed := 3.0
@export var anim_speed := 0.5
@export var regen_delay := 5.0
@export var regen_amt := 0.08
@export var shallow_scale := 50.0
@export var deep_scale := 4.0
@export var shallow_x := -16.0
@export var deep_x := 384.0
@export var shallow_speed_mult := 1.05
@export var deep_speed_mult := 0.85
@export var visibility := 1.0
var since_hit := 999.0
var animplaymult := 1.0
var animtimer: float = 0.15
@onready var healthbar: ProgressBar = $healthbar
@onready var xpbar: ProgressBar = $xpbar
@onready var light: PointLight2D = $PointLight2D
@onready var levelup_fx: AnimatedSprite2D = $levelup
func play_levelup():
	levelup_fx.visible = true
	levelup_fx.frame = 0
	levelup_fx.play("default")
func _ready():
	levelup_fx.top_level = true
	levelup_fx.visible = false
	levelup_fx.animation_finished.connect(func(): levelup_fx.visible = false)
func respawn():
	healthbar.health = healthbar.max_health
	xpbar.death()
	global_position = Vector2(0, 0)
	healthbar.update_bar()
	rotation = 0
func _physics_process(delta):
	levelup_fx.global_position = global_position
	if healthbar.health <= 0.0:
		get_node("/root/ocean/DeathScreen").show_death()
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
			_spawn_dash_trail(dash_start_pos, global_position)
		return
	if Input.is_action_just_pressed("dash") and cooldown_timer <= 0.0:
		dashing = true
		dash_timer = dash_time
		dash_hit_window = 0.2
		cooldown_timer = dash_cooldown
		dash_hit_list.clear()
		dash_dir = Vector2.RIGHT.rotated(rotation)
		dash_start_pos = global_position
	var turn = Input.get_axis("left", "right")
	rotation += turn * turn_speed * delta
	var rotforwardspeed = speed * 0.25
	var forward = Vector2.RIGHT.rotated(rotation)
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
	else:
		if $AnimatedSprite2D.frame == 1 or $AnimatedSprite2D.frame == 3:
			$AnimatedSprite2D.speed_scale = 0.0
			animtimer -= delta
			if animtimer <= 0:
				$AnimatedSprite2D.stop()
		else:
			$AnimatedSprite2D.speed_scale = 0.78 * anim_speed
		velocity = velocity.lerp(Vector2.ZERO, drag * delta)
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
func _make_ghost() -> Sprite2D:
	var ghost = Sprite2D.new()
	ghost.texture = $AnimatedSprite2D.sprite_frames.get_frame_texture($AnimatedSprite2D.animation, $AnimatedSprite2D.frame)
	ghost.global_rotation = $AnimatedSprite2D.global_rotation
	ghost.scale = $AnimatedSprite2D.scale * scale
	ghost.modulate = Color(0.75, 0.85, 1.0, 0.5)
	return ghost
func _spawn_dash_trail(from: Vector2, to: Vector2):
	var dist = from.distance_to(to)
	var count = int(dist / 10.0)
	count = clamp(count, 2, 20)
	for i in count:
		var t = float(i) / (count - 1)
		var ghost = _make_ghost()
		get_parent().add_child(ghost)
		ghost.global_position = from.lerp(to, t)
		var tw = ghost.create_tween()
		tw.tween_interval(t * 0.06)
		tw.tween_property(ghost, "modulate:a", 0.0, 0.15).set_ease(Tween.EASE_IN)
		tw.tween_callback(ghost.queue_free)
