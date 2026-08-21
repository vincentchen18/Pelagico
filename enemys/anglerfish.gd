extends CharacterBody2D
@export var speed := 192.0
@export var scale_mult := 1.0
@export var min_zone := 2
@export var max_zone := 4
@export var vision_cone := 45.0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var healthbar = $health
@onready var terrain = get_node("/root/ocean/TileMapLayer")
@onready var player = get_node_or_null("/root/ocean/Player")
@export var max_health := 200.0
@export var damage := 30.0
@export var hit_interval := 2.0
var hit_cd := 0.0
@export var regen_delay := 8.0
@export var regen_amt := 0.1
var since_hit := 999.0
var heading := Vector2.RIGHT
func hit(amount):
	healthbar.take_damage(amount)
	since_hit = 0.0
	if healthbar.health <= 0:
		die()
func _ready() -> void:
	healthbar.max_health = max_health
	healthbar.health = max_health
	healthbar.update_bar()
	scale = Vector2.ONE * scale_mult
	add_to_group("enemy")
	add_to_group("anglerfish")
	heading = Vector2.RIGHT.rotated(randf_range(0, TAU))
func _physics_process(delta: float) -> void:
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

	var target := heading
	var fleeing := false
	if player:
		var to_angler: Vector2 = (global_position - player.global_position).normalized()
		var player_facing := Vector2.RIGHT.rotated(player.rotation)
		if player_facing.dot(to_angler) > cos(deg_to_rad(vision_cone)):
			target = to_angler        # flee
			fleeing = true
		else:
			target = -to_angler       # hunt

	heading = heading.lerp(target, turn_rate_for(fleeing) * delta).normalized()
	var spd := speed
	velocity = heading * spd
	move_and_slide()

	if is_on_wall() or _zone_ahead() < min_zone or _zone_ahead() > max_zone:
		heading = -heading

	rotation = heading.angle()
	sprite.flip_v = absf(heading.angle()) > PI / 2
func turn_rate_for(fleeing: bool) -> float:
	return 3.0 if fleeing else 2.0
func _zone_ahead() -> int:
	var ahead = global_position + heading * 24.0
	var t = terrain.local_to_map(terrain.to_local(ahead))
	return terrain.zone_index(t.x, t.y)
func die():
	var xpbar = get_node_or_null("/root/ocean/Player/xpbar")
	if xpbar:
		xpbar.gain_xp(50.0)
		xpbar.update_bar()
	queue_free()
