extends CharacterBody2D

@export var speed := 60.0
@export var scale_mult := 1.0

var dir := 1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	scale = Vector2.ONE * scale_mult
	add_to_group("enemy")
	var mat: Material = sprite.material
	if mat:
		sprite.material = mat.duplicate()
	sprite.play("walk")

func _physics_process(_delta: float) -> void:
	velocity = Vector2(speed * dir, 0)
	move_and_slide()

	if is_on_wall():
		dir *= -1

	sprite.flip_h = dir < 0

func _floor_ahead() -> bool:
	var space := get_world_2d().direct_space_state
	var from := global_position + Vector2(20 * dir, 0)
	var query := PhysicsRayQueryParameters2D.create(from, from + Vector2(0, 24))
	query.collision_mask = 1
	query.exclude = [self]
	return space.intersect_ray(query).size() > 0
