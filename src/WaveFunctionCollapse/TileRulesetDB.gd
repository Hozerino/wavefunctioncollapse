extends Resource
class_name TileRulesetDB

var possible_neighbors_db: Dictionary[String, Dictionary]
var type_frequency_db: Dictionary[String, float]
var neighbor_frequency_at_dir: Dictionary[String, Dictionary] # {"FLOOR": {"NORTH": {"WATER": 0.4, "FLOOR": 0.6}}}

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
