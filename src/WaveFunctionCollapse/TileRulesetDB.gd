extends Resource
class_name TileRulesetDB

var possible_neighbors_db: Dictionary[String, Dictionary]
var neighbor_counts_db: Dictionary

# pega todos os tipos de tile que podem ser vizinhos do tile atual, considerando todas as possibilidades de colapso do tile atual
func get_all_allowed_neighbor_types(tile: WaveTile) -> Dictionary:
	var result: Dictionary = {}
	for dir in ["north", "south", "east", "west"]:
		result[dir] = []
		for tile_type in tile._available_types:
			var possible_neighbors_in_dir = possible_neighbors_db.get(tile_type, {}).get(dir, [])
			for neighbor_type in possible_neighbors_in_dir:
				if neighbor_type not in result[dir]:
					result[dir].append(neighbor_type)
	return result

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

func is_valid_neighbor(direction: String, tile_type: String, origin_tile: WaveTile) -> bool:
	assert(tile_type in possible_neighbors_db, "Tile type %s not in ruleset DB" % tile_type)

	for neighbor_type in origin_tile._available_types:
		if neighbor_type in possible_neighbors_db[tile_type].get(direction, []):
			return true
	return false
