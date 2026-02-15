extends Resource
class_name WaveFunctionCollapse

var _ruleset_db: TileRulesetDB

var _x_size: int
var _y_size: int

var grid: Array = []

var initialized = false

func _init(tile_ruleset_db: TileRulesetDB, x_size, y_size) -> void:
	_ruleset_db = tile_ruleset_db
	_x_size = x_size
	_y_size = y_size

func initialize_grid():
	grid = []
	for y in range(0, _y_size):
		var row: Array = []
		for x in range(0, _x_size):
			print("inicializando tile x=%d, y=%d" % [x, y])
			row.append(WaveTile.new(x, y, _ruleset_db.get_all_possible_tiles()))
		grid.append(row)
	initialized = true

func run_iteration() -> bool:
	if is_finished():
		print("Generation complete!")
		return true
	if not initialized:
		initialize_grid()
	var lowest_entropy_tile := _get_lowest_entropy_tile()
	lowest_entropy_tile.collapse()
	update_tiles_after_collapse(lowest_entropy_tile)
	return false

func run_to_the_end():
	while not is_finished():
		run_iteration()

func is_finished() -> bool:
	for y in range(0, _y_size):
		for x in range(0, _x_size):
			if not grid[y][x].entropy == 0:
				return false
	return true

# TODO tambem posso pegar uma lista dos N com menor entropia e escolher um igual
func _get_lowest_entropy_tile() -> WaveTile:
	var min_entropy: int = _ruleset_db.get_all_possible_tiles().size() + 1
	var min_pos: Vector2

	for y in range(0, _y_size):
		for x in range(0, _x_size):
			var tile: WaveTile = grid[y][x]
			if tile.entropy == 0:
				print("pulando tile com entro zero")
				continue
			var entropy: int = tile._available_types.size()
			if entropy < min_entropy:
				min_entropy = entropy
				min_pos = Vector2(x, y)
	assert(min_entropy > 0, "tudo bem, so falta implementar esse caso de quando ja acabou")
	assert(min_pos != null, "No valid tile found, all tiles are collapsed or have no options")
	return grid[min_pos.y][min_pos.x]

# This is the real WAVE FUNCTION COLLAPSE
func update_tiles_after_collapse(collapsed_tile: WaveTile):
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

#		 TODO arrumar esse for, antes o dir_offsets tava como up down leftright e nao entrava aqui, arrumar!!!
		for dir in possible_neighbors.keys():
			var offset = dir_offsets.get(dir)
			if offset == null:
				push_error("Unknown direction: %s" % dir)
				continue  # ignore unknown directions
			# TODO colocar x e y no tile de volta pra ele ajudar a achar os vizinhos
			var neighbor_pos = Vector2(current_tile.x, current_tile.y) + offset

			# Bounds check
			if neighbor_pos.x < 0 or neighbor_pos.x >= _x_size or neighbor_pos.y < 0 or neighbor_pos.y >= _y_size:
				continue

			var neighbor_tile: WaveTile = grid[neighbor_pos.y][neighbor_pos.x]
			if neighbor_tile.entropy == 0:
				continue  # already collapsed

			var allowed_types: Array = possible_neighbors[dir]
			var new_available_types: Array = neighbor_tile._available_types.filter(func(t): return t in allowed_types)

			# If the neighbor's possibilities shrank, update it and add to queue
			if new_available_types.size() < neighbor_tile._available_types.size():
				neighbor_tile.update_available_tiles_and_entropy(new_available_types)
				tiles_to_be_updated.append(neighbor_tile)
