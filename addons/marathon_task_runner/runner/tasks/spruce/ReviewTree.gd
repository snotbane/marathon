@tool class_name ReviewTree extends Tree

enum {
	FILE,
	BUTTONS,
}

enum {
	ACCEPT,
	INSPECT,
	REJECT,
}

enum {
	OLD,
	NEW,
	DIFF,
}

const ICON_ACCEPT := preload("uid://c53my30h15c2e")
const ICON_INSPECT := preload("uid://dtxcom0expqpo")
const ICON_REJECT := preload("uid://cx8x3diddw5ud")

@export var task : Task

@export var old_preview : ImagePreview
@export var new_preview : ImagePreview
@export var diff_bitmap : ImagePreview

var root : TreeItem
var review_paths : PackedStringArray
var item_paths : Dictionary


func _ready() -> void:
	if MarathonUtils.is_node_in_editor(self): return

	item_selected.connect(_on_item_selected)
	button_clicked.connect(_on_button_clicked)

	self.set_column_expand(BUTTONS, false)
	refresh_files.call_deferred()


func clear_items() -> void:
	review_paths.clear()
	refresh_items()


func refresh_files() -> void:
	review_paths = get_files(task.target_dir)
	refresh_items()


func refresh_items() -> void:
	self.clear()
	item_paths.clear()
	root = self.create_item()
	for i in review_paths:
		add_path_item(i)


func add_path_item(path: String):
	var result := self.create_item(root)
	item_paths[result] = path

	result.add_button(BUTTONS, ICON_ACCEPT, ACCEPT)
	result.set_button_tooltip_text(BUTTONS, ACCEPT, "Accept Changes")
	result.add_button(BUTTONS, ICON_INSPECT, INSPECT)
	result.set_button_tooltip_text(BUTTONS, INSPECT, "Manual Review")
	result.add_button(BUTTONS, ICON_REJECT, REJECT)
	result.set_button_tooltip_text(BUTTONS, REJECT, "Revert Changes")

	result.set_text(FILE, path.get_basename().get_file())
	result.set_tooltip_text(FILE, path)


func open_item(item: TreeItem) -> void:
	OS.shell_open(item_paths[item])
	OS.shell_open(get_alt_path(item_paths[item], NEW))


func accept_item(item: TreeItem) -> void:
	var old := FileAccess.open(item_paths[item], FileAccess.WRITE)
	var new := FileAccess.open(get_alt_path(item_paths[item], NEW), FileAccess.READ)

	var buffer := new.get_buffer(new.get_length())
	old.store_buffer(buffer)

	remove_path_by_item(item)
	refresh_items()
	if item == get_selected():
		old_preview.clear()
		# old_bitmap.clear()
		diff_bitmap.clear()


func reject_item(item: TreeItem) -> void:
	remove_path_by_item(item)
	refresh_items()
	if item == get_selected():
		new_preview.clear()
		# old_bitmap.clear()
		diff_bitmap.clear()


func remove_path_by_item(item: TreeItem) -> void:
	var path : String = item_paths[item]
	item_paths.erase(item)
	for i in review_paths.size():
		if review_paths[i] != path: continue
		review_paths.remove_at(i); break
	DirAccess.remove_absolute(get_alt_path(path, NEW))
	DirAccess.remove_absolute(get_alt_path(path, DIFF))


func accept_all() -> void:
	for item in item_paths.keys():
		var old := FileAccess.open(item_paths[item], FileAccess.WRITE)
		var new := FileAccess.open(get_alt_path(item_paths[item], NEW), FileAccess.READ)

		var buffer := new.get_buffer(new.get_length())
		old.store_buffer(buffer)

		remove_path_by_item(item)
	refresh_files()
	old_preview.clear()
	diff_bitmap.clear()


func reject_all() -> void:
	for item in item_paths.keys():
		remove_path_by_item(item)
	refresh_files()
	new_preview.clear()
	diff_bitmap.clear()


func open_target_directory() -> void:
	var path : String = task.target_dir
	if DirAccess.dir_exists_absolute(path): OS.shell_open(path)
	elif FileAccess.file_exists(path): OS.shell_open(path.substr(0, path.rfind("/")))


func _on_button_clicked(item:TreeItem, column:int, id:int, mouse_button_index:int) -> void:
	set_selected(item, FILE)
	var next := clampi(item.get_index() + 1, 0, self.review_paths.size() - 1)
	match id:
		ACCEPT: accept_item(item); select_tree_item_by_index(next)
		INSPECT: open_item(item)
		REJECT: reject_item(item); select_tree_item_by_index(next)



func _on_item_selected() -> void:
	var selected := get_selected()
	var path : String = item_paths[selected] if selected and item_paths.has(selected) else ""
	old_preview.value = get_alt_path(path, OLD)
	new_preview.value = get_alt_path(path, NEW)
	diff_bitmap.value = get_alt_path(path, DIFF)


func get_files(path: String) -> PackedStringArray:
	if DirAccess.dir_exists_absolute(path):
		return get_all_matching_files(path, RegEx.create_from_string(task.filter_include), RegEx.create_from_string(task.filter_exclude))
	elif FileAccess.file_exists(path):
		if RegEx.create_from_string(task.filter_include).search(path) and FileAccess.file_exists(get_alt_path(path, NEW)):
			return [ path ]
	return []


func get_all_matching_files(path: String, include: RegEx, exclude: RegEx) -> PackedStringArray:
	var result : PackedStringArray = []
	var dir := DirAccess.open(path)
	if not dir.dir_exists(path): return result

	dir.list_dir_begin()
	var file := dir.get_next()
	while file:
		var full_path := path.path_join(file)
		if dir.current_is_dir():
			result.append_array(get_all_matching_files(full_path, include, exclude))
		else:
			if	(include.get_pattern() == "" or include.search(file) != null) and \
				(exclude.get_pattern() == "" or exclude.search(file) == null) and \
				FileAccess.file_exists(get_alt_path(full_path, NEW)):
					result.push_back(full_path)
		file = dir.get_next()
	dir.list_dir_end()
	return result


func get_alt_path(old: String, type: int = NEW) -> String:
	if type == OLD: return old

	var file : String = old.substr(old.rfind("/") + 1)
	var split := file.rfind(".")
	var p_name := file.substr(0, split)
	var ext := file.substr(split)

	var p_root := Task.TEMP_DIR_PATH
	var suffix : String
	match type:
		NEW:	suffix = "__new"
		DIFF:	suffix = "__diff"

	return p_root.path_join(p_name + suffix + ext)


func select_tree_item_by_index(idx: int) -> void:
	if root == null:
		return

	var queue: Array = [root]
	var current_index = 0

	while queue.size() > 0:
		var item: TreeItem = queue.pop_front()
		if current_index == idx:
			self.set_selected(item, FILE)
			return
		current_index += 1

		var child = item.get_first_child()
		while child:
			queue.append(child)
			child = child.get_next()
