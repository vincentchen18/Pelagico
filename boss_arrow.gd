extends Polygon2D

@export var orbit_radius := 60.0
@export var max_stage := 5
@onready var player = get_parent()

func _ready() -> void:
	polygon = PackedVector2Array([
		Vector2(30, 0),
		Vector2(-10, -12),
		Vector2(-10, 12)
	])
	color = Color(1, 0.2, 0.2)
	top_level = true

func _physics_process(_delta: float) -> void:
	var xpbar = player.get_node_or_null("xpbar")
	if xpbar == null or xpbar.stage < max_stage:
		visible = false
		return
	var boss = get_tree().get_first_node_in_group("boss")
	if not boss or not is_instance_valid(boss):
		visible = false
		return
	visible = true
	var to_boss = boss.global_position - player.global_position
	var ang = to_boss.angle()
	global_position = player.global_position + Vector2(orbit_radius, 0).rotated(ang)
	global_rotation = ang
