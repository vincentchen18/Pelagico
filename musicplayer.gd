extends AudioStreamPlayer
@onready var player = get_node("/root/ocean/Player")
@onready var terrain = get_node("/root/ocean/TileMapLayer")
@export var fade_start_x := 192.0   # tile where music starts fading (into zone 3)
@export var fade_end_x := 232.0     # tile where music is silent
@export var full_volume_db := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var tx = player.global_position.x / 32.0
	var t = clamp((tx - fade_start_x) / (fade_end_x - fade_start_x), 0.0, 1.0)
	volume_db = lerp(full_volume_db, -40.0, t)
