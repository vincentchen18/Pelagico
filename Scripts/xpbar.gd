extends ProgressBar

var max_xp := 40.0
var xp := 0.0
var stage := 0
@export var growth_thresholds := [40.0, 200.0, 800.0, 3000.0, 999999999999999999999999999999999999999.0]
func gain_xp(num: float):
	xp += num
	if xp >= growth_thresholds[stage]:
		stage += 1
		xp -= growth_thresholds[stage-1]
		max_value = growth_thresholds[stage]
	update_bar()
		
func death():
	xp /= 2.0
	update_bar()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	top_level = true
	var fill := StyleBoxFlat.new()

	fill.bg_color = Color("#FBC835") 
	add_theme_stylebox_override("fill", fill)

	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.1, 0.1, 0.1)   
	add_theme_stylebox_override("background", bg)
	update_bar()
func update_bar():
	value = xp
	var t := float(xp) / max_xp
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("#FBC835") 
	add_theme_stylebox_override("fill", fill)

func _physics_process(delta: float) -> void:
	position = get_parent().get_node("AnimatedSprite2D").global_position + Vector2(-13, 25)
