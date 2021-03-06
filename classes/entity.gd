extends Area2D
### public class member vars
# is selectable by player
export (bool) var is_selectable = null

### internal class member variables
var root = null
var selected = null
var hex_outline = null
var hexmap = null
var red_dot = null
var type = null
var path = null
var id = null

## Called every time the node is added to the scene.
func _ready():
	set_fixed_process(true)
	if get_tree().is_editor_hint():
		# This is only executed in editor
		self._snap_to_grid()
	else:
		# Normal init when inside the game
		set_fixed_process(true)
		# Get necessary siblings
		root = get_tree().get_current_scene()
		hex_outline = find_node('HexOutline')
		# @TODO Maybe get active map scene later, to get correct hex? Maybe let map be generic and have member "active"?
		hexmap = root.find_node('MapZones')
		red_dot = root.find_node('RedDot')
		# Default function calls
		self._snap_to_grid()
		
func _fixed_process(delta):
	if get_tree().is_editor_hint():
		# This is only executed in editor
		self._snap_to_grid()

# # Handle input
# func _input_event(viewport, event, shape_idx):
# 	# if selectable, attempt to select
# 	if event.type == InputEvent.MOUSE_BUTTON and event.button_index == BUTTON_LEFT and event.pressed:
# 		if is_selectable() and not is_selected():
# 			select()

# Getter for selectable
func is_selectable():
	return self.is_selectable

# Getter for state of selection
func is_selected():
	return self.selected

# Getter for type
func get_type():
	return self.type

# Setter for path array
func set_path(path_array):
	self.path = path_array
	
# Getter for path array
func get_path():
	return self.path

# Setter for id
func set_id(id):
	self.id = id

# Select this entity
func select():
	# deselect every other entity first
	root.deselect_all_entities()
	# now select this entity
	self.selected = true
	self._show_marker('red')
	root.selected_unit = self.id
	
# Deselect this entity
func deselect():
	self.selected = false
	self._hide_marker()
	if root.selected_unit != null:
		root.selected_unit = null
		
# Internal helper functions
func _show_marker(color):
	# show hex outline, color must be string representation of common color name
	hex_outline.set_modulate(globals.getColor(color))
	hex_outline.set_opacity(1)
	
# hide any visible marker
func _hide_marker():
	hex_outline.set_opacity(0)

# Snap entity to the next suitable hex-tile
func _snap_to_grid():
	var grid_coords = hexmap.world_to_map(self.get_global_pos())
	var world_coords = get_centered_grid_pos(grid_coords, Vector2(-6,0))
	self.set_pos(world_coords)

# Helper function that returns the centered coordinates corrected
# by given offset
# @input {Vector2} offset, this can depend on entity type
# @input {Vector2} grid coordinates of a hex
# @returns {Vector2} global coordinates that represent the center of a hex
func get_centered_grid_pos(grid_coords, offset):
	var world_coords = hexmap.map_to_world(grid_coords)
	world_coords.x += ((hexmap.get_cell_size().x/2) + offset.x)
	world_coords.y += ((hexmap.get_cell_size().y/2) + offset.y)
	return world_coords