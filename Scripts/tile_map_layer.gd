extends TileMapLayer
const sourceid = 0
var worldmap: Dictionary = {}
var noise = FastNoiseLite.new()
var chunkvector = Vector2(0 , 0)
const oceantilespos = Vector2i(0, 0)
const walltilepos = Vector2i(0, 1)
var chunkoffset: Vector2 = Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.seed = randi()
	noise.frequency = 0.12
	for i in range (-1, 2):
		for j in range(-1, 2):
			chunkoffset = Vector2(j, i)
			gen_chunk(chunkvector.x + chunkoffset.x, chunkvector.y + chunkoffset.y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

#generate chunk

func gen_chunk(cx, cy) -> void:
	var tilepos: Vector2 = Vector2.ZERO
	var currentchunk: Array = []
	var startx: int = cx * 8
	var starty: int = cy * 8
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
				currentlis.append("o")
				tilepos = oceantilespos
			set_cell(Vector2i(globalx, globaly), sourceid, tilepos)
		currentchunk.append(currentlis)
	var chunkkey = Vector2i(cx, cy)
	worldmap[chunkkey] = currentchunk 	
