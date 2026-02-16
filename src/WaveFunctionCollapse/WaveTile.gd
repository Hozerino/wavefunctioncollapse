extends Resource
class_name WaveTile

var entropy          = INF
var _available_types = []
var _grid_copy: Array
var x: int
var y: int
var collapsed = false

func collapse(chosen_type: String):
	assert(_available_types.size() > 0, "No available types to collapse to!")
	assert(chosen_type != null, "pick_random returned null, which should not happen if size > 0")
	assert(chosen_type in _available_types, "Chosen type '%s' is not in available types: %s" % [chosen_type, _available_types])
	print("setting my available types to ", chosen_type)

	return update_available_types_and_entropy([chosen_type])


func update_available_types_and_entropy(new_list: Array[String]):
	if collapsed:
		return
	if new_list.size() == 1:
		print("collapsing at x=%d, y=%d to type %s" % [x, y, new_list[0]])
		_available_types = new_list
		collapsed = true
		return
	_available_types = new_list
	entropy = _available_types.size()

func _init(_x: int, _y: int, grid: Array, available_types: Array[String] = []):
	assert(available_types.size() > 0, "A tile must start with at least one available type!")
	x = _x
	y = _y
	_grid_copy = grid
	_available_types = available_types
	entropy = available_types.size()


func _get_neighbor(direction: String, grid: Array) -> WaveTile:
	var dir_offsets = {
		"north": Vector2.UP,
		"south": Vector2.DOWN,
		"west": Vector2.LEFT,
		"east": Vector2.RIGHT
	}

	var offset = dir_offsets.get(direction)
	assert(offset != null, "Unknown direction: %s" % direction)

	var neighbor_pos = Vector2(x, y) + offset

	if neighbor_pos.x < 0 or neighbor_pos.x >= grid[0].size() or neighbor_pos.y < 0 or neighbor_pos.y >= grid.size():
		return null

	return grid[neighbor_pos.y][neighbor_pos.x]


func get_neighbors(grid: Array) -> Dictionary:
	var neighbors = {}
	for direction in ["north", "south", "west", "east"]:
		var neighbor = _get_neighbor(direction, grid)
		if neighbor != null:
			neighbors[direction] = neighbor
	return neighbors
