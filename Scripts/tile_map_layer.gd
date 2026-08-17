extends TileMapLayer
const sourceid = 0
var walltilepos = Vector2i(1,2)
const CRAB = preload("res://enemys/crab.tscn")
const SARDINE = preload("res://enemys/sardine.tscn")
const ANGLERFISH = preload("res://enemys/anglerfish.tscn")

const CRAB_CHANCE = 0.05
const SARDINE_CHANCE = 0.04
var worldmap: Dictionary = {}
var noise = FastNoiseLite.new()
var depthnoise = FastNoiseLite.new()
var oceantilespos = Vector2i(0, 1)
var world_seed := 0
@export var player: Node2D
@export var unload_dist := 4

func _ready() -> void:
	world_seed = randi()   # hardcode a fixed int here for a reproducible world
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.seed = world_seed
	noise.frequency = 0.12
	depthnoise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	depthnoise.seed = world_seed + 1
	depthnoise.frequency = 0.03
func _process(_delta: float) -> void:
	var playerchunky: Vector2i = playerchunk(player.global_position)
	for x in range(-2 + playerchunky.x, 3 + playerchunky.x):
		for y in range(-2 + playerchunky.y, 3 + playerchunky.y):
			gen_chunk(x, y)
	unload_far(playerchunky)
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
func cell_rng(gx: int, gy: int, salt: int) -> RandomNumberGenerator:
	var rng = RandomNumberGenerator.new()
	rng.seed = hash(Vector3i(gx, gy, world_seed + salt))
	return rng
func zone_index(globalx: int, globaly: int) -> int:
	var wobble = depthnoise.get_noise_1d(globaly) * 6.0
	var wx = globalx + wobble
	if wx > 384:   return 4   # abyssal (cx > 48)
	elif wx > 192: return 3   # midnight (cx > 24)
	elif wx > 64:  return 2   # twilight (cx > 8)
	elif wx > -16: return 1   # shallow (cx > -2)
	else:          return 0   # sand/beach
func zone_tiles(globalx: int, globaly: int) -> Array:
	match zone_index(globalx, globaly):
		4: return [Vector2i(1,1), Vector2i(1,3)] # abyssal
		3: return [Vector2i(0,3), Vector2i(1,3)] # midnight
		2: return [Vector2i(0,2), Vector2i(1,2)] # twilight
		1: return [Vector2i(0,1), Vector2i(1,2)] # shallow
		_: return [Vector2i(0,0), Vector2i(0,0)] # beach
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
					if noise.get_noise_2d(globalx, globaly + 1) > 0.45:
						spawn_for_zone(Vector2i(globalx, globaly), globalx, globaly)
			set_cell(Vector2i(globalx, globaly), sourceid, tilepos, 0)
		currentchunk.append(currentlis)
	worldmap[chunkkey] = currentchunk
func spawn_for_zone(cell: Vector2i, globalx: int, globaly: int) -> void:
	var z = zone_index(globalx, globaly)
	match z:
		0:
			pass
		1:
			if 1 == 1: spawn(ANGLERFISH, cell)
			if cell_rng(globalx, globaly, 1).randf() < CRAB_CHANCE: spawn(CRAB, cell)
		2:
			if cell_rng(globalx, globaly, 1).randf() < CRAB_CHANCE: spawn(CRAB, cell)
			if cell_rng(globalx, globaly, 2).randf() < SARDINE_CHANCE: spawn_school(SARDINE, cell, globalx, globaly)
		3:
			if cell_rng(globalx, globaly, 2).randf() < SARDINE_CHANCE: spawn_school(SARDINE, cell, globalx, globaly)
		4:
			pass
func spawn(scene: PackedScene, cell: Vector2i) -> void:
	var inst = scene.instantiate()
	get_parent().add_child(inst)
	inst.global_position = to_global(map_to_local(cell))
func spawn_school(scene: PackedScene, cell: Vector2i, gx: int, gy: int, min_count := 4, max_count := 6, spread := 40.0) -> void:
	var rng = cell_rng(gx, gy, 3)
	var count = rng.randi_range(min_count, max_count)
	var center = to_global(map_to_local(cell))
	var placed = 0
	var tries = 0
	while placed < count and tries < count * 5:
		tries += 1
		var pos = center + Vector2(rng.randf_range(-spread, spread), rng.randf_range(-spread, spread))
		var tcell = local_to_map(to_local(pos))
		if get_cell_source_id(tcell) == -1 or not _is_wall(tcell):
			var inst = scene.instantiate()
			get_parent().add_child(inst)
			inst.global_position = pos
			placed += 1
func playerchunk(playerpos) -> Vector2i:
	var pixelsperchunk: float = 256
	var playerchunkx: int = int(floor(playerpos.x / pixelsperchunk))
	var playerchunky: int = int(floor(playerpos.y / pixelsperchunk))
	return Vector2i(playerchunkx, playerchunky)
func _is_wall(tcell: Vector2i) -> bool:
	var atlas = get_cell_atlas_coords(tcell)
	return atlas in [Vector2i(1,2), Vector2i(1,3), Vector2i(0,0)]
