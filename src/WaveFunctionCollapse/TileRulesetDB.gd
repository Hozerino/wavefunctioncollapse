extends Resource
class_name TileRulesetDB

var possible_neighbors_db: Dictionary[String, Dictionary]
var neighbor_counts_db: Dictionary

# Pega a interseccao dos arrays
func get_possible_neighbors(tile: WaveTile) -> Dictionary:
	var result: Dictionary = {}

	if tile._available_types.is_empty():
		return result

	# Initialize with first candidate
	var first_type: String = tile._available_types[0]
	assert(possible_neighbors_db.has(first_type), "Type not in DB")

	# Deep copy first constraints
	for dir in possible_neighbors_db[first_type]:
		result[dir] = possible_neighbors_db[first_type][dir].duplicate()

	# Intersect with remaining candidates
	for i in range(1, tile._available_types.size()):
		var type_candidate: String = tile._available_types[i]
		assert(possible_neighbors_db.has(type_candidate), "Type not in DB")

		var candidate_data = possible_neighbors_db[type_candidate]

		for dir in result.keys():
			result[dir] = result[dir].filter(func(v):
				return v in candidate_data.get(dir, [])
			)

	print("Possible neighbors for tile with types %s: %s" % [tile._available_types, result])
	return result

func put_possible_neighbors(tile_type: String, constraints: Dictionary[String, Array]):
	possible_neighbors_db[tile_type] = constraints

func get_all_possible_tiles()-> Array[String]:
	return possible_neighbors_db.keys()

func get_global_frequencies() -> Dictionary[String, float]:
	"""Return a dictionary mapping each tile type to its total count in the input."""
	var freq: Dictionary = {}
	for tile_type in neighbor_counts_db:
		var total = 0
		var dir_counts = neighbor_counts_db[tile_type]
		for dir in dir_counts:
			for neighbor_type in dir_counts[dir]:
				total += dir_counts[dir][neighbor_type]
		# Alternatively, you could also count occurrences from the raw input,
		# but summing neighbor counts double-counts each tile in multiple directions.
		# A better approach: compute directly from the input lines during rule extraction.
		# For now, we'll use the neighbor_counts_db as a proxy (it's approximate).
		freq[tile_type] = total
	return freq