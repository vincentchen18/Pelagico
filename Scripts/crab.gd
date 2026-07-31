extends CharacterBody2D

@export var speed := 60.0
@export var scale_mult := 1.0

var dir := 1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var max_health := 40.0
@export var damage := 5.0

@onready var healthbar = $health
@export var hit_interval := 1.0
var hit_cd := 0.0
@export var regen_delay := 8.0
@export var regen_amt := 0.02
var since_hit := 999.0

func hit(amount):
	healthbar.take_damage(amount)
	since_hit = 0.0
	if healthbar.health <= 0:
		die()
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

	velocity = Vector2(speed * dir, 0)
	move_and_slide()
	if is_on_wall():
		dir *= -1
	sprite.flip_h = dir < 0
func die():
	var xpbar = get_node_or_null("/root/ocean/Player/xpbar")
	if xpbar:
		xpbar.xp += 4.0
		xpbar.update_bar()
	queue_free()
func _ready() -> void:
	healthbar.max_health = max_health
	healthbar.health = max_health
	healthbar.update_bar()
	scale = Vector2.ONE * scale_mult
	add_to_group("enemy")



func _floor_ahead() -> bool:
	var space := get_world_2d().direct_space_state
	var from := global_position + Vector2(20 * dir, 0)
	var query := PhysicsRayQueryParameters2D.create(from, from + Vector2(0, 24))
	query.collision_mask = 1
	query.exclude = [self]
	return space.intersect_ray(query).size() > 0
