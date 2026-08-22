extends ProgressBar

var max_health := 20000.0
var health := max_health

func take_damage(amount):
	health = clamp(health-amount, 0, max_health)
	update_bar()
	
func heal(amount):
	health = clamp(health+amount, 0, max_health)
	update_bar()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	top_level = true
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.2, 0.8, 0.3) 
	add_theme_stylebox_override("fill", fill)

	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.1, 0.1, 0.1)   
	add_theme_stylebox_override("background", bg)
	update_bar()
func update_bar():
	value = health
	max_value = max_health
	var t := float(health) / max_health
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(1.0 - t, t, 0.2)  # make red->green as health go up
	add_theme_stylebox_override("fill", fill)

func _physics_process(_delta: float) -> void:
	global_position = get_parent().get_node("Camera2D").global_position + Vector2(-13, 20)
