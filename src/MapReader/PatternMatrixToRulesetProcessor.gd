extends Resource
class_name PatternMatrixToRulesetProcessor

@export var pattern_size: int = 2

func build_rules_db(matrix: Array) -> TileRulesetDB:
	var pattern_matrix := build_pattern_matrix(matrix, pattern_size)
	return _build_rules_from_pattern_matrix(pattern_matrix)

func build_pattern_matrix(matrix: Array, size: int) -> Array:
	var result: Array = []

	var height = matrix.size()
	var width = matrix[0].size()

	for y in range(height - size + 1):
		var row: Array = []
		for x in range(width - size + 1):
			var pattern_key = extract_pattern_key(matrix, x, y, size)
			row.append(pattern_key)
		result.append(row)

	return result

func extract_pattern_key(matrix: Array, start_x: int, start_y: int, size: int) -> String:
	var parts: Array = []

	for dy in range(size):
		var row_part := ""
		for dx in range(size):
			row_part += str(matrix[start_y + dy][start_x + dx])
		parts.append(row_part)

	return "|".join(parts)

func _build_rules_from_pattern_matrix(matrix: Array) -> TileRulesetDB:
	var ruleset_db = TileRulesetDB.new()

	for y in range(matrix.size()):
		var line = matrix[y]
		for x in range(line.size()):
			var tile_type: String = line[x]

			if tile_type == " ":
				continue # optional safety if you ever indent

			if not ruleset_db.possible_neighbors_db.has(tile_type):
				ruleset_db.possible_neighbors_db[tile_type] = {
					"north": [],
					"south": [],
					"east": [],
					"west": []
				}

			if y > 0:
				ruleset_db.possible_neighbors_db[tile_type]["north"].append(matrix[y - 1][x])
			if y < matrix.size() - 1:
				ruleset_db.possible_neighbors_db[tile_type]["south"].append(matrix[y + 1][x])
			if x > 0:
				ruleset_db.possible_neighbors_db[tile_type]["west"].append(line[x - 1])
			if x < line.size() - 1:
				ruleset_db.possible_neighbors_db[tile_type]["east"].append(line[x + 1])

	# Now lets populate type_frequency_db, GDScript
	ruleset_db.type_frequency_db = ({} as Dictionary[String, float])
	for y in range(matrix.size()):
		var line = matrix[y]
		for x in range(line.size()):
			var tile_type: String = line[x]
			if tile_type == " ":
				continue # optional safety if you ever indent
			ruleset_db.type_frequency_db[tile_type] = ruleset_db.type_frequency_db.get(tile_type, 0) + 1

# Neighbor frequency for directions, useful for later...
#	for tile_type in ruleset_db.possible_neighbors_db.keys():
#		ruleset_db.neighbor_frequency_at_dir[tile_type] = {}
#		for dir in ruleset_db.possible_neighbors_db[tile_type].keys():
#			var neighbor_list = ruleset_db.possible_neighbors_db[tile_type][dir]
#			var frequency_dict = {}
#			for neighbor in neighbor_list:
#				frequency_dict[neighbor] = frequency_dict.get(neighbor, 0) + 1
#			# Convert counts to frequencies
#			var total_neighbors = neighbor_list.size()
#			if total_neighbors > 0:
#				for neighbor in frequency_dict.keys():
#					frequency_dict[neighbor] /= total_neighbors
#			ruleset_db.neighbor_frequency_at_dir[tile_type][dir] = frequency_dict

	return ruleset_db
