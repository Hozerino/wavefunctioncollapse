extends Resource
class_name WaveFunctionCollapse

var _ruleset_db: TileRulesetDB

var _x_size: int
var _y_size: int

var grid: Array = []

var initialized = false
var finished = false

func _init(tile_ruleset_db: TileRulesetDB, x_size, y_size) -> void:
	_ruleset_db = tile_ruleset_db
	_x_size = x_size
	_y_size = y_size

func initialize_grid():
	grid = []
	for y in range(0, _y_size):
		var row: Array = []
		for x in range(0, _x_size):
			row.append(WaveTile.new(x, y, _ruleset_db.get_all_possible_tiles()))
		grid.append(row)
	initialized = true
	finished = false

func run_iteration() -> bool:
	check_finished()
	if finished:
		print("Generation complete!")
		return true
	if not initialized:
		initialize_grid()
	var tiles = _get_lowest_entropy_tiles(1)
	var lowest_entropy_tile : WaveTile = tiles.pick_random()

	# Copy possibilities so we can retry
	var original_types = lowest_entropy_tile._available_types.duplicate()

	while original_types.size() > 0:
		var chosen = original_types.pick_random()
		original_types.erase(chosen)

		lowest_entropy_tile.update_available_tiles_and_entropy([chosen])
		lowest_entropy_tile.entropy = 0

		return update_tiles_after_collapse(lowest_entropy_tile)

	# If we reach here → all choices failed
	assert(false, "Hard contradiction at (%d, %d)" % [lowest_entropy_tile.x, lowest_entropy_tile.y])
	return false

func run_to_the_end():
	while not finished:
		run_iteration()

func check_finished():
	for y in range(0, _y_size):
		for x in range(0, _x_size):
			var tile = grid[y][x]
			if tile._available_types.size() != 1:
				finished = false
				return
	finished = true

func _get_lowest_entropy_tiles(N: int) -> Array:
	var lowest_entropy_tiles := []
	var entropy_list := {}

	for y in range(0, _y_size):
		for x in range(0, _x_size):
			var tile: WaveTile = grid[y][x]
			if tile.entropy == 0:
				continue
			var entropy: int = tile._available_types.size()
			entropy_list[Vector2(x, y)] = entropy

	# pegando as menores entropias
	var sorted_keys = entropy_list.keys().duplicate()
	sorted_keys.sort_custom(func(a, b): return entropy_list[a] < entropy_list[b])
	for i in range(min(N, sorted_keys.size())):
		lowest_entropy_tiles.append(grid[sorted_keys[i].y][sorted_keys[i].x])
	return lowest_entropy_tiles

func _get_lowest_entropy_tile() -> WaveTile:
	var min_entropy: int = _ruleset_db.get_all_possible_tiles().size() + 1
	var min_pos: Vector2

	for y in range(0, _y_size):
		for x in range(0, _x_size):
			var tile: WaveTile = grid[y][x]
			if tile.entropy == 0:
				continue
			var entropy: int = tile._available_types.size()
			if entropy < min_entropy:
				min_entropy = entropy
				min_pos = Vector2(x, y)
	assert(min_entropy > 0, "tudo bem, so falta implementar esse caso de quando ja acabou")
	assert(min_pos != null, "No valid tile found, all tiles are collapsed or have no options")
	return grid[min_pos.y][min_pos.x]

# This is the real WAVE FUNCTION COLLAPSE
func update_tiles_after_collapse(collapsed_tile: WaveTile) -> bool:
	# Queue for propagation (BFS)
	var tiles_to_be_updated: Array = [collapsed_tile]

	# Map direction names to vectors

	var dir_offsets = {
		"north": Vector2.UP,
		"south": Vector2.DOWN,
		"west": Vector2.LEFT,
		"east": Vector2.RIGHT
	}

	while not tiles_to_be_updated.is_empty():
		var current_tile: WaveTile = tiles_to_be_updated.pop_front()
		var possible_neighbors: Dictionary = _ruleset_db.get_possible_neighbors(current_tile)

		for dir in possible_neighbors.keys():
			var offset = dir_offsets.get(dir)
			assert(offset != null, "Unknown direction: %s" % dir)

			var neighbor_pos = Vector2(current_tile.x, current_tile.y) + offset

			if neighbor_pos.x < 0 or neighbor_pos.x >= _x_size or neighbor_pos.y < 0 or neighbor_pos.y >= _y_size:
				continue

			var neighbor_tile: WaveTile = grid[neighbor_pos.y][neighbor_pos.x]
			if neighbor_tile.entropy == 0:
				continue

			var allowed_types: Array = possible_neighbors[dir]
			var new_available_types: Array = neighbor_tile._available_types.filter(func(t): return t in allowed_types)
			# 🚨 CONTRADICTION DETECTED, returning false
			if new_available_types.is_empty():
				push_error("Contradiction detected at (%d, %d) when processing neighbor in direction %s" % [neighbor_tile.x, neighbor_tile.y, dir])
				return false

			if new_available_types.size() < neighbor_tile._available_types.size():
				neighbor_tile.update_available_tiles_and_entropy(new_available_types)
				tiles_to_be_updated.append(neighbor_tile)

	return true
