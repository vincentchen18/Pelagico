extends CharacterBody2D
@export var scale_mult := 1.0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var healthbar = $health
@onready var player = get_node_or_null("/root/ocean/Player")
@export var max_health := 50.0
@export var fire_interval := 2.0
@export var projectile_speed := 150.0
@export var projectile_damage := 20.0
@export var regen_delay := 10.0
@export var regen_amt := 0.03
const PROJECTILE = preload("res://enemys/scallopshots.tscn")
var since_hit := 999.0
var fire_cd := 0.0
var push_vel := Vector2.ZERO
@export var push_strength := 120.0
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
	add_to_group("scallop")
func _physics_process(delta: float) -> void:
	since_hit += delta
	if since_hit >= regen_delay and healthbar.health < healthbar.max_health:
		healthbar.heal(healthbar.max_health * regen_amt * delta)
	if not player:
		return
	var to_player: Vector2 = player.global_position - global_position
	rotation = to_player.angle()
	fire_cd = max(fire_cd - delta, 0.0)
	if fire_cd <= 0.0:
		fire_cd = fire_interval
		shoot(to_player.normalized())
	push_vel = push_vel.lerp(Vector2.ZERO, delta * 4.0)
	if player and global_position.distance_to(player.global_position) < 40:
		var away = (global_position - player.global_position).normalized()
		push_vel = away * push_strength
	velocity = push_vel
	move_and_slide()
func shoot(dir: Vector2) -> void:
	var p = PROJECTILE.instantiate()
	get_parent().add_child(p)
	p.global_position = global_position
	p.setup(dir, projectile_speed, projectile_damage)
func die():
	var xpbar = get_node_or_null("/root/ocean/Player/xpbar")
	if xpbar:
		xpbar.gain_xp(9.0)
		xpbar.update_bar()
	queue_free()
