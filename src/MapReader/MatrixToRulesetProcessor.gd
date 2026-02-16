extends Resource
class_name MatrixToRulesetProcessor

func build_rules_db(input: String) -> TileRulesetDB:
	var ruleset_db = TileRulesetDB.new()
#	ruleset_db.possible_neighbors_db["W"] = {
#		"north": ["F"],
#		"south": ["F"],
#		"east":  ["F"],
#		"west":  ["F"]
#	}
#
#	ruleset_db.possible_neighbors_db["F"] = {
#		"north": ["W"],
#		"south": ["W"],
#		"east":  ["W"],
#		"west":  ["W"]
#	}
#	if true: return ruleset_db

	# Normalize line endings first
	var clean_input = input.strip_edges().replace("\r", "")
	var lines = clean_input.split("\n", false)

	for y in range(lines.size()):
		var line = lines[y]
		for x in range(line.length()):
			var tile_type = line[x]

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
				ruleset_db.possible_neighbors_db[tile_type]["north"].append(lines[y - 1][x])
			if y < lines.size() - 1:
				ruleset_db.possible_neighbors_db[tile_type]["south"].append(lines[y + 1][x])
			if x > 0:
				ruleset_db.possible_neighbors_db[tile_type]["west"].append(line[x - 1])
			if x < line.length() - 1:
				ruleset_db.possible_neighbors_db[tile_type]["east"].append(line[x + 1])

	return ruleset_db
#

func build_rules_db_toroidal_sei_la(input: String) -> TileRulesetDB:
	var ruleset_db = TileRulesetDB.new()

	var clean_input = input.strip_edges().replace("\r", "")
	var lines = clean_input.split("\n", false)

	var height = lines.size()
	var neighbor_counts = {}

	for y in range(height):
		var line = lines[y]
		var width = line.length()

		for x in range(width):
			var tile = line[x]
			if tile == " ":
				continue

			if not neighbor_counts.has(tile):
				neighbor_counts[tile] = {
					"north": {},
					"south": {},
					"east": {},
					"west": {}
				}

			# 🟢 WRAPPED NEIGHBORS
			var north_y = (y - 1 + height) % height
			var south_y = (y + 1) % height
			var west_x  = (x - 1 + width) % width
			var east_x  = (x + 1) % width

			var north_neighbor = lines[north_y][x]
			var south_neighbor = lines[south_y][x]
			var west_neighbor  = line[west_x]
			var east_neighbor  = line[east_x]

			if north_neighbor != " ":
				neighbor_counts[tile]["north"][north_neighbor] = neighbor_counts[tile]["north"].get(north_neighbor, 0) + 1

			if south_neighbor != " ":
				neighbor_counts[tile]["south"][south_neighbor] = neighbor_counts[tile]["south"].get(south_neighbor, 0) + 1

			if west_neighbor != " ":
				neighbor_counts[tile]["west"][west_neighbor] = neighbor_counts[tile]["west"].get(west_neighbor, 0) + 1

			if east_neighbor != " ":
				neighbor_counts[tile]["east"][east_neighbor] = neighbor_counts[tile]["east"].get(east_neighbor, 0) + 1

	# Store rules normally
	for tile in neighbor_counts:
		ruleset_db.possible_neighbors_db[tile] = {
			"north": neighbor_counts[tile]["north"].keys(),
			"south": neighbor_counts[tile]["south"].keys(),
			"east":  neighbor_counts[tile]["east"].keys(),
			"west":  neighbor_counts[tile]["west"].keys()
		}

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
