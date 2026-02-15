extends Resource
class_name WaveTile

var entropy          = INF
var _available_types = []
var x: int
var y: int

var neighbors: Dictionary[String, WaveTile] = {
	"north": null,
	"south": null,
	"east": null,
	"west": null
}

func collapse():
	assert(_available_types.size() > 0, "No available types to collapse to!")
	var chosen_type = _available_types.pick_random()
	assert(chosen_type != null, "pick_random returned null, which should not happen if size > 0")
	print("setting my available types to ", chosen_type)
	_available_types = [chosen_type]
	entropy = 0

func collapse_weighted(weight_func: Callable) -> void:
	"""Choose a tile type from _available_types using weights provided by weight_func.
	   weight_func(type) should return a float weight for that type."""
	if entropy == 0:
		return  # already collapsed

	# Compute weights for each available type
	var weights = []
	var total_weight = 0.0
	for type in _available_types:
		var w = weight_func.call(type)
		weights.append(w)
		total_weight += w

	# Choose randomly based on weights
	var r = randf() * total_weight
	var accumulated = 0.0
	for i in range(_available_types.size()):
		accumulated += weights[i]
		if r <= accumulated:
			_available_types = [_available_types[i]]
			entropy = 0
			return

	# Fallback (should not happen)
	_available_types = [_available_types[0]]
	entropy = 0	

func update_available_tiles_and_entropy(new_list: Array[String]):
	_available_types = new_list
	entropy = _available_types.size()

func _init(_x: int, _y: int, available_types: Array[String] = []):
	assert(available_types.size() > 0, "A tile must start with at least one available type!")
	x = _x
	y = _y
	_available_types = available_types
	entropy = available_types.size()
	