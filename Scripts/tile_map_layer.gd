extends TileMapLayer
const sourceid = 0
var worldmap: Dictionary = {}
var noise = FastNoiseLite.new()
var chunkvector = Vector2(0 , 0)
const oceantilespos = Vector2i(0, 0)
const walltilepos = Vector2i(0, 1)
@export var player: Node2D
var chunkoffset: Vector2 = Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.seed = randi()
	noise.frequency = 0.12

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var playerchunky: Vector2i = playerchunk(player.global_position)
	for x in range(-2 + playerchunky.x, 3 + playerchunky.x):
		for y in range(-2 + playerchunky.y, 3 + playerchunky.y):
			gen_chunk(x, y) 

#generate chunk
func gen_chunk(cx, cy) -> void:
	var chunkkey = Vector2i(cx, cy)
	var tilepos: Vector2 = Vector2.ZERO
	var currentchunk: Array = []
	var startx: int = cx * 8
	var starty: int = cy * 8
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
			set_cell(Vector2i(globalx, globaly), sourceid, tilepos)
		currentchunk.append(currentlis)

	worldmap[chunkkey] = currentchunk 	
func playerchunk(playerpos) -> Vector2i:
	var pixelsperchunk: float = 256
	var playerchunkx: int = int(floor(playerpos.x/pixelsperchunk))
	var playerchunky: int = int(floor(playerpos.y/pixelsperchunk))
	return Vector2i(playerchunkx, playerchunky)
