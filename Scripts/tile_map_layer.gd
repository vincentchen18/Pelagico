extends TileMapLayer

const sourceid = 0
var walltilepos = Vector2i(1,2)
const CRAB = preload("res://enemys/crab.tscn")
const CRAB_CHANCE = 0.02

var worldmap: Dictionary = {}
var noise = FastNoiseLite.new()
var depthnoise = FastNoiseLite.new()
var chunkvector = Vector2(0, 0)
var oceantilespos = Vector2i(0, 1)
var chunkoffset: Vector2 = Vector2.ZERO

@export var player: Node2D
@export var unload_dist := 4

func unload_far(pc: Vector2i) -> void:
	for key in worldmap.keys():
		if abs(key.x - pc.x) > unload_dist or abs(key.y - pc.y) > unload_dist:
			clear_chunk(key)
			worldmap.erase(key)

func clear_chunk(key: Vector2i) -> void:
	var minx = key.x * 8 * 32
	var maxx = minx + 8 * 32
	var miny = key.y * 8 * 32
	var maxy = miny + 8 * 32
	for e in get_tree().get_nodes_in_group("enemy"):
		var p = e.global_position
		if p.x >= minx and p.x < maxx and p.y >= miny and p.y < maxy:
			e.queue_free()
	for i in range(8):
		for j in range(8):
			erase_cell(Vector2i(key.x * 8 + j, key.y * 8 + i))

func _ready() -> void:
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.seed = randi()
	noise.frequency = 0.12
	depthnoise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	depthnoise.seed = randi()
	depthnoise.frequency = 0.03

func _process(_delta: float) -> void:
	var playerchunky: Vector2i = playerchunk(player.global_position)
	for x in range(-2 + playerchunky.x, 3 + playerchunky.x):
		for y in range(-2 + playerchunky.y, 3 + playerchunky.y):
			gen_chunk(x, y)
	unload_far(playerchunky)

func zone_tiles(globalx: int, globaly: int) -> Array:
	match zone_index(globalx, globaly):
		4: return [Vector2i(1,1), Vector2i(1,3)] # abyssal
		3: return [Vector2i(0,3), Vector2i(1,3)] # midnight
		2: return [Vector2i(0,2), Vector2i(1,2)] #twilight
		1: return [Vector2i(0,1), Vector2i(1,2)] #shallow
		_: return [Vector2i(0,0), Vector2i(0,0)] #beach

func gen_chunk(cx, cy) -> void:
	var chunkkey = Vector2i(cx, cy)
	var tilepos: Vector2i = Vector2i.ZERO
	var currentchunk: Array = []
	var startx: int = cx * 8
	var starty: int = cy * 8
	if worldmap.has(chunkkey): return
	for i in range(8):
		var currentlis: Array = []
		for j in range(8):
			var globalx = startx + j
			var globaly = starty + i
			var zt = zone_tiles(globalx, globaly)
			oceantilespos = zt[0]
			walltilepos = zt[1]
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
					if noise.get_noise_2d(globalx, globaly + 1) > 0.45 and randf() < CRAB_CHANCE:
						spawn_crab(Vector2i(globalx, globaly))
			set_cell(Vector2i(globalx, globaly), sourceid, tilepos, 0)
		currentchunk.append(currentlis)
	worldmap[chunkkey] = currentchunk

func spawn_crab(cell: Vector2i) -> void:
	var inst = CRAB.instantiate()
	get_parent().add_child(inst)
	inst.global_position = to_global(map_to_local(cell))

func zone_index(globalx: int, globaly: int) -> int:
	var wobble = depthnoise.get_noise_1d(globaly) * 6.0
	var wx = globalx + wobble
	if wx > 352:   return 4
	elif wx > 160: return 3
	elif wx > 64:  return 2
	elif wx > -16: return 1
	else:          return 0

func spawn_for_zone(cell: Vector2i, globalx: int, globaly: int) -> void:
	var z = zone_index(globalx, globaly)
	var r = randf()
	match z:
		0, 1:
			if r < CRAB_CHANCE: spawn(CRAB, cell)
		2:
			if r < 0.015: pass   #more mobs later
		3, 4:
			if r < 0.02: pass  

func spawn(scene: PackedScene, cell: Vector2i) -> void:
	var inst = scene.instantiate()
	get_parent().add_child(inst)
	inst.global_position = to_global(map_to_local(cell))

func playerchunk(playerpos) -> Vector2i:
	var pixelsperchunk: float = 256
	var playerchunkx: int = int(floor(playerpos.x / pixelsperchunk))
	var playerchunky: int = int(floor(playerpos.y / pixelsperchunk))
	return Vector2i(playerchunkx, playerchunky)
