extends Resource
class_name MatrixToRulesetProcessor

func build_rules_db(input: String) -> TileRulesetDB:
	var ruleset_db = TileRulesetDB.new()

	# Normalize and split input lines
	var clean_input = input.strip_edges().replace("\r", "")
	var lines = clean_input.split("\n", false)

	# Optional: ensure all lines have the same length (pad with spaces or truncate)
	# Here we simply assume they are equal; you may add validation.

	# Structure: tile_type -> direction -> {neighbor_tile: count}
	var neighbor_counts = {}

	for y in range(lines.size()):
		var line = lines[y]
		for x in range(line.length()):
			var tile = line[x]
			if tile == " ":
				continue  # ignore spaces (treated as empty/not a tile)

			# Initialize tile entry if missing
			if not neighbor_counts.has(tile):
				neighbor_counts[tile] = {
					"north": {},
					"south": {},
					"east": {},
					"west": {}
				}

			# Record north neighbor
			if y > 0:
				var neighbor = lines[y-1][x]
				if neighbor != " ":
					neighbor_counts[tile]["north"][neighbor] = neighbor_counts[tile]["north"].get(neighbor, 0) + 1

			# Record south neighbor
			if y < lines.size() - 1:
				var neighbor = lines[y+1][x]
				if neighbor != " ":
					neighbor_counts[tile]["south"][neighbor] = neighbor_counts[tile]["south"].get(neighbor, 0) + 1

			# Record west neighbor
			if x > 0:
				var neighbor = line[x-1]
				if neighbor != " ":
					neighbor_counts[tile]["west"][neighbor] = neighbor_counts[tile]["west"].get(neighbor, 0) + 1

			# Record east neighbor
			if x < line.length() - 1:
				var neighbor = line[x+1]
				if neighbor != " ":
					neighbor_counts[tile]["east"][neighbor] = neighbor_counts[tile]["east"].get(neighbor, 0) + 1

	# Populate the ruleset database
	for tile in neighbor_counts:
		# Ensure the tile entry exists
		if not ruleset_db.possible_neighbors_db.has(tile):
			ruleset_db.possible_neighbors_db[tile] = {
				"north": [],
				"south": [],
				"east": [],
				"west": []
			}

		# Store unique neighbors (keys of the count dictionaries) for simple constraint checks
		for dir_name in ["north", "south", "east", "west"]:
			ruleset_db.possible_neighbors_db[tile][dir_name] = neighbor_counts[tile][dir_name].keys()

	# Optionally store the full counts for weighted sampling (extend TileRulesetDB as needed)
	ruleset_db.neighbor_counts_db = neighbor_counts

	return ruleset_db

func get_input_matrix(input: String) -> Array:
	var input_as_matrix: Array = []
	var clean_input = input.strip_edges().replace("\r", "")
	var lines = clean_input.split("\n", false)

	for y in range(lines.size()):
		var row: Array = []
		var line = lines[y]

		for x in range(line.length()):
			var _char = line[x]

			if _char == " ":
				continue # ignore accidental indentation

			row.append(_char)

		input_as_matrix.append(row)
	return input_as_matrix
