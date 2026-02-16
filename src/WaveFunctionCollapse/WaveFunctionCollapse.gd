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
	randomize()

func initialize_grid():
	grid = []
	for y in range(0, _y_size):
		var row: Array = []
		for x in range(0, _x_size):
			row.append(WaveTile.new(x, y, grid, _ruleset_db.get_all_possible_tiles()))
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
	var tiles = _get_lowest_entropy_tiles(3)
	var lowest_entropy_tile : WaveTile = tiles.pick_random()

	# Copy possibilities so we can retry
	var original_types = lowest_entropy_tile._available_types.duplicate()

	while original_types.size() > 0:
		var chosen = original_types.pick_random()
		original_types.erase(chosen)

		lowest_entropy_tile.collapse(chosen)
		var success: bool = propagate(lowest_entropy_tile)
		if success:
			return true
		else:
			print("cointractdicts???")

	# If we reach here → all choices failed
	print("Hard contradiction at (%d, %d)" % [lowest_entropy_tile.x, lowest_entropy_tile.y])
	return false

func run_to_the_end():
	while not finished:
		run_iteration()
		check_finished()

func check_finished():
	for y in range(0, _y_size):
		for x in range(0, _x_size):
			var tile = grid[y][x]
			if not tile.collapsed:
				finished = false
				return
	finished = true

func _get_lowest_entropy_tiles(N: int) -> Array:
	var lowest_entropy_tiles := []
	var entropy_list := {}

	for y in range(0, _y_size):
		for x in range(0, _x_size):
			var tile: WaveTile = grid[y][x]
			if(tile.x == 8 and tile.y == 9):
				print("olha o bugado fdp")
			if tile.collapsed:
				continue
			var entropy: int = tile.entropy
			entropy_list[Vector2(x, y)] = entropy

	# pegando as menores entropias
	var sorted_keys = entropy_list.keys().duplicate()
	sorted_keys.sort_custom(func(a, b): return entropy_list[a] < entropy_list[b])
	for i in range(min(N, sorted_keys.size())):
		lowest_entropy_tiles.append(grid[sorted_keys[i].y][sorted_keys[i].x])
	return lowest_entropy_tiles


var opposite_dirs: Dictionary = {
	"north": "south",
	"south": "north",
	"east": "west",
	"west": "east"
}
func propagate(starting_tile) -> bool:
	# Queue for propagation (BFS)
	var tiles_to_be_updated: Array = [starting_tile]
	print("Starting propagation of tile x=%d, y=%d with neighbors_size: %s" % [starting_tile.x, starting_tile.y, tiles_to_be_updated.size()])

	while not tiles_to_be_updated.is_empty():
		var current_tile: WaveTile = tiles_to_be_updated.pop_front()
		var current_tile_neighbors: Dictionary = current_tile.get_neighbors(grid)
		var possible_neighbors: Dictionary = _ruleset_db.get_all_allowed_neighbor_types(current_tile)

		for neighbor_dir in current_tile_neighbors.keys():
			var neighbor_tile                             = current_tile_neighbors[neighbor_dir]
			var types_that_neighbor_can_be = possible_neighbors[neighbor_dir]

			# check if the neighbor can connect to the collapsed tile on the opposite direction
				# if not, we have a contradiction
			var neighbor_new_available_types: Array[String] = neighbor_tile._available_types.filter(func(neighbor_type_candidate):
				return neighbor_type_candidate in types_that_neighbor_can_be
			)

			if neighbor_new_available_types.size() == 0:
				print("Contradiction found at tile x=%d, y=%d" % [neighbor_tile.x, neighbor_tile.y])
				return false

			if neighbor_new_available_types.size() < neighbor_tile._available_types.size():
				neighbor_tile.update_available_types_and_entropy(neighbor_new_available_types)
				tiles_to_be_updated.append(neighbor_tile)




#	while not tiles_to_be_updated.is_empty():
#		var current_tile: WaveTile = tiles_to_be_updated.pop_front()
#
#		var current_neighbors: Dictionary = current_tile.get_neighbors(grid)
#		var new_available_types: Array[String] = current_tile._available_types.duplicate()
#
#		for neighbor_dir in current_neighbors.keys():
#			var opposite_dirs: Dictionary = {
#				"north": "south",
#				"south": "north",
#				"east": "west",
#				"west": "east"
#			}
#			var neighbor_to_me_dir        = opposite_dirs[neighbor_dir]
#			var neighbor_tile      = current_neighbors[neighbor_dir]
#			new_available_types = new_available_types.filter(func(type_candidate):
#				return _ruleset_db.is_valid_neighbor(neighbor_to_me_dir, type_candidate, neighbor_tile)
#			)
#
#			current_tile.update_available_types_and_entropy(new_available_types)
#			for neighbor_of_neighbor in current_tile.get_neighbors(grid).values():
#				tiles_to_be_updated.append(neighbor_of_neighbor)

	return true
