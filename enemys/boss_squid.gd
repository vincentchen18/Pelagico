extends CharacterBody2D
@export var scale_mult := 1.0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var healthbar = $health
@onready var player = get_node_or_null("/root/ocean/Player")
@export var max_health := 10000.0
@export var damage := 120.0
@export var hit_interval := 1.0
var hit_cd := 0.0
@export var cruise_speed := 180.0
@export var pulse_freq := 3.0
@export var pulse_amount := 40.0
@export var dash_speed := 440.0
@export var dash_time := 0.35
@export var dash_interval_min := 3.0
@export var dash_interval_max := 6.0
@export var fire_interval := 4.0
@export var aim_time := 0.5
@export var projectile_speed := 150.0
@export var projectile_damage := 40.0
@export var regen_delay := 25.0 # take a long tim eto heal so player is still making progres
@export var regen_amt := 0.01
@export var wake_range := 600.0
@export var engage_range := 600.0
const PROJECTILE = preload("res://enemys/projectile.tscn")
var heading := Vector2.RIGHT
var pulse_t := 0.0
var dash_cd := 0.0
var dashing := false
var dash_timer := 0.0
var dash_dir := Vector2.RIGHT
var fire_cd := 0.0
var aiming := false
var aim_timer := 0.0
var since_hit := 999.0
var awake := false
var home_pos := Vector2.ZERO
var home_set := false
func hit(amount):
	healthbar.take_damage(amount)
	since_hit = 0.0
	awake = true
	if healthbar.health <= 0:
		die()
func _ready() -> void:
	healthbar.max_health = max_health
	healthbar.health = max_health
	healthbar.update_bar()
	scale = Vector2.ONE * scale_mult
	add_to_group("enemy")
	add_to_group("boss")
	dash_cd = randf_range(dash_interval_min, dash_interval_max)
func _physics_process(delta: float) -> void:
	if not awake:
		var near = player and global_position.distance_to(player.global_position) < wake_range
		if near:
			awake = true
		else:
			velocity = Vector2.ZERO
			move_and_slide()
			return
	if not home_set:
		home_pos = global_position
		home_set = true
	since_hit += delta
	if since_hit >= regen_delay and healthbar.health < healthbar.max_health:
		healthbar.heal(healthbar.max_health * regen_amt * delta)
	hit_cd = max(hit_cd - delta, 0.0)
	if hit_cd <= 0.0:
		for body in $attackHitbox.get_overlapping_bodies():
			if body.has_method("hit"):
				body.hit(damage)
				hit_cd = hit_interval
				break
	var player_near = player and global_position.distance_to(player.global_position) < engage_range
	var to_player := Vector2.RIGHT
	if player_near:
		to_player = (player.global_position - global_position).normalized()
	else:
		to_player = (home_pos - global_position).normalized()
	if aiming:
		heading = heading.lerp(-to_player, 6.0 * delta).normalized()
		velocity = velocity.lerp(Vector2.ZERO, 8.0 * delta)
		aim_timer -= delta
		if aim_timer <= 0.0:
			aiming = false
			shoot(to_player)
			fire_cd = fire_interval
	elif dashing:
		dash_timer -= delta
		velocity = dash_dir * dash_speed
		heading = dash_dir
		if dash_timer <= 0.0:
			dashing = false
			dash_cd = randf_range(dash_interval_min, dash_interval_max)
	else:
		dash_cd = max(dash_cd - delta, 0.0)
		if dash_cd <= 0.0 and player_near:
			dashing = true
			dash_timer = dash_time
			dash_dir = to_player
		heading = heading.lerp(to_player, 1.5 * delta).normalized()
		pulse_t += delta
		var pulse := (sin(pulse_t * pulse_freq) * 0.5 + 0.5) * pulse_amount
		velocity = heading * (cruise_speed + pulse)
		fire_cd = max(fire_cd - delta, 0.0)
		if fire_cd <= 0.0 and player_near:
			aiming = true
			aim_timer = aim_time
	move_and_slide()
	if dashing and is_on_wall():
		dashing = false
		dash_cd = randf_range(dash_interval_min, dash_interval_max)
	rotation = heading.angle() - PI / 2
func shoot(dir: Vector2) -> void:
	var p = PROJECTILE.instantiate()
	get_parent().add_child(p)
	p.global_position = global_position
	p.setup(dir, projectile_speed, projectile_damage)
func die():
	win()
	queue_free()
func win():
	print("YOU WIN") # replace this with the actual winscreen
