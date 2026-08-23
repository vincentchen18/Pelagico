extends Area2D
var velocity := Vector2.ZERO
var damage := 8.0
@export var lifetime := 6.0
func setup(dir: Vector2, speed: float, dmg: float) -> void:
	velocity = dir * speed
	damage = dmg
	rotation = dir.angle()
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	await get_tree().create_timer(lifetime).timeout
	queue_free()
func _physics_process(delta: float) -> void:
	global_position += velocity * delta
func _on_body_entered(body):
	if body.has_method("hit"):
		body.hit(damage)
		queue_free()
	elif body is TileMapLayer:
		queue_free()
