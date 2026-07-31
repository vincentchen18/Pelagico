extends TileMapLayer

const sourceid = 2
const walltilepos = Vector2i(0, 1)
const CRAB = preload("res://enemys/crab.tscn")
const CRAB_CHANCE = 0.02

var worldmap: Dictionary = {}
var noise = FastNoiseLite.new()
var chunkvector = Vector2(0, 0)
var oceantilespos = Vector2i(0, 0)
var chunkoffset: Vector2 = Vector2.ZERO

@export var player: Node2D

func _ready() -> void:
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.seed = randi()
	noise.frequency = 0.12

func _process(_delta: float) -> void:
	var playerchunky: Vector2i = playerchunk(player.global_position)
	for x in range(-2 + playerchunky.x, 3 + playerchunky.x):
		for y in range(-2 + playerchunky.y, 3 + playerchunky.y):
			gen_chunk(x, y)

func gen_chunk(cx, cy) -> void:
	var chunkkey = Vector2i(cx, cy)
	var tilepos: Vector2i = Vector2i.ZERO
	var currentchunk: Array = []
	var startx: int = cx * 8
	var starty: int = cy * 8
	if cx > 5:
		oceantilespos = Vector2i(0, 3)
	else:
		oceantilespos = Vector2i(0, 0)
	if worldmap.has(chunkkey): return
	for i in range(8):
		var currentlis: Array = []
		for j in range(8):
			var globalx = startx + j
			var globaly = starty + i
			var noisevalue = noise.get_noise_2d(globalx, globaly)
			if noisevalue > 0.45:
				currentlis.append("x")
				tilepos = walltilepos
			else:
				if noise.get_noise_2d(globalx - 1, globaly) > 0.45 and noise.get_noise_2d(globalx, globaly - 1) > 0.45 and noise.get_noise_2d(globalx + 1, globaly) > 0.45 and noise.get_noise_2d(globalx, globaly + 1) > 0.45:
					currentlis.append("x")
					tilepos = walltilepos
				else:
					currentlis.append("o")
					tilepos = oceantilespos
					if noise.get_noise_2d(globalx, globaly + 1) > 0.45 and randf() < CRAB_CHANCE+2:
						spawn_crab(Vector2i(globalx, globaly))
			set_cell(Vector2i(globalx, globaly), sourceid, tilepos, 0)
		currentchunk.append(currentlis)
	worldmap[chunkkey] = currentchunk

func spawn_crab(cell: Vector2i) -> void:
	var inst = CRAB.instantiate()
	get_parent().add_child(inst)
	inst.global_position = to_global(map_to_local(cell))

func playerchunk(playerpos) -> Vector2i:
	var pixelsperchunk: float = 256
	var playerchunkx: int = int(floor(playerpos.x / pixelsperchunk))
	var playerchunky: int = int(floor(playerpos.y / pixelsperchunk))
	return Vector2i(playerchunkx, playerchunky)
