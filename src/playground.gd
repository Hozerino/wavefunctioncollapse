extends Control

@onready var output_visual_grid: GridContainer = $OutputVisualGrid
@onready var input_visual_grid: GridContainer = $InputVisualGrid

@export var x_size: int
@export var y_size: int

@export var input = """
111111111111111111111111111111111111111111111111111111111111
111111111111111111111111111111111111111111111111111111111111
111111111111111111111111111111111111111222222222111111111111
111111111111111111111111111111111111222288888888222221111111
111111111111122222221111111111111112288888888888888822111111
111111111122224444222211111111111112888888888888888882111111
111111111224444444444221111111111112222288888888882221111111
111111111244444444444442111111111111111122222222222111111111
111111112444444444444442111111111111111111111111111111111111
111111112244444444444422111111111111111111111111111111111111
111111111224444444444221111111111111111111111111111111111111
111111111122222222222211111111111111111111222211111111111111
111111111111111111111111111111111111111122277722111111111111
111111111111111111111111111111111111111227777772111111111111
111111111111111111111111111111111111112277777772211111111111
111111111111111111111111111111111111122777777777211111111111
111111111111111111111111111111111111127777777777221111111111
111111111111111111111111111111111111227777777777721111111111
111111111111111111111111111111111111277777777777721111111111
111111111111111111111111111111111111227777777777721111111111
111111111111111111111111111111111111127777777777721111111111
111111111111111111111111111111111111112777777777721111111111
111111112222222111111111111111111111111222222222211111111111
111111222333332222221111111111111111111111111111111111111111
111112233333333333321111111111111111111111111111111111111111
111112333333333333221111111111111111111111111111111111111111
111111222333333332211111111111111111111111111111111111111111
111111112222222222111111111111111111111111111111111111111111
111111111111111111111111111111111111111111111111111111111111
111111111111111111111111111111111111111111111111111111111111
"""
#XXXXXXXXXXXXXXXXX
#XXXXEEEEEEEEEXXXX
#XXXXEAAAAAAAEXXXX
#XXXXEAAAAAAAEXXXX
#XXXXEAAAAAAAEXXXX
#XXXXEAAAAAAAEXXXX
#XXXXEEEEEEEEEXXXX
#XXXXXXXXXXXXXXXXX

#XXXXXXXXXXXXXXXXX
#XXXX811111112XXXX
#XXXX7AAAAAAA3XXXX
#XXXX7AAAAAAA3XXXX
#XXXX7AAAAAAA3XXXX
#XXXX7AAAAAAA3XXXX
#XXXX655555554XXXX
#XXXXXXXXXXXXXXXXX


var matrix_to_ruleset_processor: PatternMatrixToRulesetProcessor = PatternMatrixToRulesetProcessor.new()
var ruleset_db: TileRulesetDB = matrix_to_ruleset_processor.build_rules_db(get_input_as_matrix(input))

@onready var wfc :WaveFunctionCollapse = WaveFunctionCollapse.new(ruleset_db, x_size, y_size)


func _ready() -> void:
	wfc.initialize_grid()
	populate_grid_with_matrix_of_strings(input_visual_grid, get_input_as_matrix(input))
	populate_grid_container(output_visual_grid)



func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed(&"ui_accept"):
		wfc.run_iteration()
		populate_grid_container(output_visual_grid)
	if Input.is_action_pressed(&"ui_cancel"):
		wfc.run_to_the_end()
		populate_grid_container(output_visual_grid)


# Helper: creates a label with common styling (border, alignment, expand flags)
func _create_styled_label(text: String, bg_color: Color) -> Label:
	var label = Label.new()
	label.text = text

	# Usar monospace
	var system_font = SystemFont.new()
	system_font.font_names = ["Monospace"] # Fallback names
	label.add_theme_font_override("font", system_font)
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color.BLACK)



# Make the label expand to fill the grid cell
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	# Build stylebox with common border settings
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = Color(0, 0, 0)        # white border
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.set_corner_radius_all(2)             # slight rounding (optional)

	label.add_theme_stylebox_override("normal", style)
	return label


func populate_grid_container(grid_container: GridContainer) -> void:
	for child in grid_container.get_children():
		child.queue_free()

	if wfc.finished and matrix_to_ruleset_processor.pattern_size > 1:
		var expanded = get_1x1_matrix(wfc.grid, matrix_to_ruleset_processor.pattern_size)
		populate_grid_with_matrix_of_strings(grid_container, expanded)
		return

	grid_container.columns = x_size

	for y in range(0, y_size):
		for x in range(0, x_size):
			var tile: WaveTile = wfc.grid[y][x]
			var text: String
			var bg_color: Color

			if wfc.finished:
				text = str(tile._available_types[0])
			else:
				text = str(tile.entropy)

			bg_color = string_to_color(text)
			var label = _create_styled_label(text, bg_color)
			grid_container.add_child(label)

func populate_grid_with_matrix_of_strings(grid_container: GridContainer, matrix: Array) -> void:
	# Remove any existing child controls to avoid duplicates
	for child in grid_container.get_children():
		child.queue_free()

	# If matrix is empty, nothing to show
	if matrix.is_empty():
		return

	# Determine the number of columns from the first row (assume rectangular matrix)
	var num_cols = matrix[0].size()
	grid_container.columns = num_cols

	# Create a Label for each cell
	for y in range(matrix.size()):
		var line: Array = matrix[y]
		for x in range(line.size()):
			var tile_type: String = line[x]
			var bg_color = string_to_color(tile_type)

			var label = _create_styled_label(tile_type, bg_color)
			grid_container.add_child(label)


func string_to_color(text: String) -> Color:
	var hash_value: int = abs(text.hash())
	hash_value = hash_value * 2654435761  # Knuth multiplicative hash

	var hue: float = float(hash_value % 360) / 360.0
	return Color.from_hsv(hue, 0.8, 0.9)

func get_input_as_matrix(input: String) -> Array:
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

# TODO algum matrix utils da vida?
func get_1x1_matrix(grid: Array, pattern_size: int) -> Array:
	var output: Array = []

	for y in range(grid.size()):
		for dy in range(pattern_size):
			var row: Array = []
			for x in range(grid[0].size()):
				var pattern_key: String      = grid[y][x]._available_types[0]
				var split: PackedStringArray = pattern_key.split("|")
				var pattern_row: String      = split[dy]

				for char in pattern_row:
					row.append(char)
			output.append(row)

	return output
