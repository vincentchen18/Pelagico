extends ProgressBar

var max_xp := 40.0
var xp := 0.0
var stage := 0
@export var growth_thresholds := [40, 120, 400, 1000]
func gain_xp(num: float):
	xp += num
	if xp > growth_thresholds[stage]:
		stage += 1
		xp -= growth_thresholds[stage-1]
	update_bar()
		
func death():
	xp /= 2
	update_bar()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	top_level = true
	var fill := StyleBoxFlat.new()

	fill.bg_color = Color("#89c9ef") 
	add_theme_stylebox_override("fill", fill)

	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.1, 0.1, 0.1)   
	add_theme_stylebox_override("background", bg)
	update_bar()
func update_bar():
	value = xp
	var t := float(xp) / max_xp
	var fill := StyleBoxFlat.new()
	add_theme_stylebox_override("fill", fill)

func _physics_process(_delta: float) -> void:
	position = get_parent().get_node("AnimatedSprite2D").global_position + Vector2(-13, 25)
