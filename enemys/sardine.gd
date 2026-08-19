extends CharacterBody2D
@export var speed := 50.0
@export var scale_mult := 1.0
@export var min_zone := 2
@export var max_zone := 3
@export var school_radius := 90.0
@export var separation_dist := 24.0
@export var turn_rate := 2.0
@export var flee_radius := 150.0
@export var flee_time := 0.8
@export var flee_mult := 1.6

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var healthbar = $health
@onready var terrain = get_node("/root/ocean/TileMapLayer")
@onready var player = get_node_or_null("/root/ocean/Player")

@export var max_health := 20.0
@export var damage := 5.0
@export var hit_interval := 0.5
var hit_cd := 0.0
@export var regen_delay := 8.0
@export var regen_amt := 0.1
var since_hit := 999.0

var heading := Vector2.RIGHT
var flee_timer := 0.0
var flee_dir := Vector2.RIGHT

func hit(amount):
	healthbar.take_damage(amount)
	since_hit = 0.0
	flee_timer = flee_time
	if healthbar.health <= 0:
		die()

func _ready() -> void:
	healthbar.max_health = max_health
	healthbar.health = max_health
	healthbar.update_bar()
	scale = Vector2.ONE * scale_mult
	add_to_group("enemy")
	add_to_group("sardine")
	heading = Vector2.RIGHT.rotated(randf_range(0, TAU))

func _physics_process(delta: float) -> void:
	since_hit += delta
	if since_hit >= regen_delay and healthbar.health < healthbar.max_health:
		healthbar.heal(healthbar.max_health * regen_amt * delta)

	flee_timer = max(flee_timer - delta, 0.0)

	if player and global_position.distance_to(player.global_position) < flee_radius:
		flee_dir = (global_position - player.global_position).normalized()
		flee_timer = flee_time

	var target := _school_heading()
	if flee_timer > 0.0:
		target = flee_dir
	hit_cd = max(hit_cd - delta, 0.0)
	if hit_cd <= 0.0:
		for body in $attackHitbox.get_overlapping_bodies():
			if body.has_method("hit"):
				body.hit(damage)
				hit_cd = hit_interval
				break
	heading = heading.lerp(target, turn_rate * delta).normalized()

	var spd := speed * (flee_mult if flee_timer > 0.0 else 1.0)
	velocity = heading * spd
	move_and_slide()

	if is_on_wall() or _zone_ahead() < min_zone or _zone_ahead() > max_zone:
		heading = -heading

	rotation = heading.angle()
	sprite.flip_v = absf(heading.angle()) > PI / 2

func _school_heading() -> Vector2:
	var cohesion := Vector2.ZERO
	var separation := Vector2.ZERO
	var alignment := Vector2.ZERO
	var n := 0
	for other in get_tree().get_nodes_in_group("sardine"):
		if other == self:
			continue
		var offset: Vector2 = other.global_position - global_position
		var d := offset.length()
		if d < school_radius:
			cohesion += other.global_position
			alignment += other.heading
			if d < separation_dist and d > 0.0:
				separation -= offset / d
			n += 1
	if n == 0:
		return heading
	cohesion = (cohesion / n - global_position).normalized()
	alignment = (alignment / n).normalized()
	return (cohesion * 0.6 + alignment * 0.8 + separation * 1.4).normalized()

func _zone_ahead() -> int:
	var ahead = global_position + heading * 24.0
	var t = terrain.local_to_map(terrain.to_local(ahead))
	return terrain.zone_index(t.x, t.y)

func die():
	var xpbar = get_node_or_null("/root/ocean/Player/xpbar")
	if xpbar:
		xpbar.gain_xp(2.0)
		xpbar.update_bar()
	queue_free()
