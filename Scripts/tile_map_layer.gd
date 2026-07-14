extends TileMapLayer
var worldmap: Dictionary = {}
var noise = FastNoiseLite.new()
var chunkvector = Vector2(0 , 0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.seed = randi()
	noise.frequency = 0.12
	gen_chunk()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#generate chunk

func gen_chunk() -> void:
	var currentchunk: Array = []
	for i in range(8):
		var currentlis: Array = []
		for j in range(8):
			var noisevalue = noise.get_noise_2d(j, i)
			if noisevalue > 0.45:
				currentlis.append("x")
			else:
				currentlis.append("o")
		currentchunk.append(currentlis)
	worldmap[chunkvector] = currentchunk
	print(worldmap)

