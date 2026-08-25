extends ProgressBar

var max_xp := 40.0
var xp := 0.0
var stage := 0
@onready var player: CharacterBody2D = get_parent()
@onready var healthbar: ProgressBar = get_parent().get_node("healthbar")
@export var growth_thresholds := [40.0, 200.0, 800.0, 2000.0, 3000.0, 999999999999999999999999999999999999999.0]
@export var health_bars := [100.0, 200.0, 400.0, 700.0, 1000.0, 2000.0]
@export var damages := [20.0, 60.0, 110.0, 160.0, 250.0, 360.0]
@export var speeds := [235.0, 260.0, 300.0, 350.0, 400.0, 440.0]
@export var regens := [0.08, 0.1, 0.1, 0.12, 0.14, 0.16]
@export var regens_delays := [5.0, 4.5, 4.0, 3.7, 3.5, 3.3]
@export var visibility := [1.0, 1.2, 1.3, 1.5, 1.8, 2.0]
@export var dash_cooldowns := [1.5, 1.3, 1.0, 0.8, 0.6, 0.5]

func gain_xp(num: float):
	xp += num
	while stage < growth_thresholds.size() - 1 and xp >= growth_thresholds[stage]:
		player.play_levelup()
		xp -= growth_thresholds[stage]
		stage += 1
		max_value = growth_thresholds[stage]
		max_xp = growth_thresholds[stage]
		healthbar.max_health = health_bars[stage]
		healthbar.health = health_bars[stage] # full heal
		healthbar.update_bar()
		player.base_damage = damages[stage]
		player.speed = speeds[stage]
		player.dash_speed = speeds[stage] * 2
		player.regen_amt = regens[stage]
		player.regen_delay = regens_delays[stage]
		player.since_hit = 5.0
		player.visibility = visibility[stage]
		player.dash_cooldown = dash_cooldowns[stage]
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
	if stage >= growth_thresholds.size() - 1:
		max_value = 1
		value = 1
	else:
		max_value = max_xp
		value = xp
	var t := float(value) / max_value
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("#FBC835")
	add_theme_stylebox_override("fill", fill)

func _physics_process(delta: float) -> void:
	position = get_parent().get_node("AnimatedSprite2D").global_position + Vector2(-13, 25)
