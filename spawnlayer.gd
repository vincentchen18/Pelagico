extends TileMapLayer

const CRAB := preload("res://enemys/crab.tscn")

var spawned := {}

func spawn_chunk(chunk_pos: Vector2i, chunk_size: int) -> void:
	if spawned.has(chunk_pos):
		return
	spawned[chunk_pos] = true

	var parent := get_parent()
	for x in chunk_size:
		for y in chunk_size:
			var cell := Vector2i(chunk_pos.x * chunk_size + x, chunk_pos.y * chunk_size + y)
			var data := get_cell_tile_data(cell)
			if data == null:
				continue
			if data.get_custom_data("spawn") != "crab":
				continue

			var inst := CRAB.instantiate()
			parent.add_child(inst)
			inst.global_position = to_global(map_to_local(cell))
			erase_cell(cell)
