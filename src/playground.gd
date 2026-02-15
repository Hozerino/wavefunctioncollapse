extends Control

@onready var output_visual_grid: GridContainer = $OutputVisualGrid
@onready var input_visual_grid: GridContainer = $InputVisualGrid

@export var x_size: int
@export var y_size: int

@export var input = """
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXBBBBBBBBBBBBBBBBBBXXXXXXX
XXXX811111112XXXXXXXXXXXXXXBBBBBBBBBBBBBBBBBBBBBBXXXXX
XXXX7AAAAAAA3XXXXXXXXXXXXBBBBBBBBBBBBBBBBBBBBBBBBBXXXX
XXXX7AAAAAAA3XXXXXXXXXXXBBBBBBBBBBBBBBBBBBBBBBBBBBXXXX
XXXX7AAAAAAA3XXXXXXXXXXXXXXXBBBBBBBBBBBBBBBBBBBBBXXXXX
XXXX7AAAAAAA3XXXXXXXXXXXXXXXXXXXXBBBBBBBBBBBBBBBXXXXXX
XXXX655555554XXXXXXXXXXXXXXXXXXXXXXXXXXXBBBBXXXXXXXXXX
"""


var matrix_to_ruleset_processor: MatrixToRulesetProcessor = MatrixToRulesetProcessor.new()
var ruleset_db: TileRulesetDB = matrix_to_ruleset_processor.build_rules_db(input)

@onready var wfc :WaveFunctionCollapse = WaveFunctionCollapse.new(ruleset_db, x_size, y_size)


func _ready() -> void:
	wfc.initialize_grid()
	populate_grid_with_matrix_of_strings(input_visual_grid, matrix_to_ruleset_processor.get_input_matrix(input))
	wfc.run_to_the_end()
	populate_grid_container(output_visual_grid)



func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed(&"ui_accept"):
		wfc.initialize_grid()
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
	# Remove any existing child controls to avoid duplicates
	for child in grid_container.get_children():
		child.queue_free()

	# Set the number of columns to match the grid's width
	grid_container.columns = x_size

	# Create a Label for each cell
	for y in range(0, y_size):
		for x in range(0, x_size):
			var tile: WaveTile = wfc.grid[y][x]
			var text: String
			var bg_color: Color

			if wfc.finished:
				text = str(tile._available_types[0])
				bg_color = string_to_color(text)
			else:
				text = str(tile.entropy)
				bg_color = Color(0.2, 0.2, 0.2)

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
