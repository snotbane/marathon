
@tool class_name MarathonUtils

static func get_paths_in_folder(root := "res://", include := RegEx.create_from_string(".*")) -> PackedStringArray:
	var dir := DirAccess.open(root)
	if not dir: return []

	var result : PackedStringArray = []
	dir.list_dir_begin()
	var file : String = dir.get_next()
	while file:
		var next := root.path_join(file)
		if dir.current_is_dir():
			result.append_array(get_paths_in_folder(next, include))
		elif include.search(file):
			result.push_back(next)
		file = dir.get_next()
	return result

static func get_project_preferred_path(path: String) -> String:
	if path.begins_with("res://"): return path
	var project_root_global := ProjectSettings.globalize_path("res://")
	project_root_global = project_root_global.substr(0, project_root_global.length() - 1)
	var path_global := ProjectSettings.globalize_path(path)
	var path_belongs_to_project := path_global.begins_with(project_root_global)
	return ("res:/" + path_global.substr(project_root_global.length())) if path_belongs_to_project else path_global


static func print_ancestry(node: Node) -> void:
	print("\n\nAncestry of %s: " % node)
	var cursor := node.get_parent()
	while cursor:
		print(cursor)
		cursor = cursor.get_parent()


static func is_node_in_editor(node: Node) -> bool:
	var editor := node.get_parent()
	while editor:
		if editor.get_parent().name == "MainScreen": break
		editor = editor.get_parent()

	return editor.name.contains("CanvasItemEditor") if editor else false

static func is_folder_inside_other(a: String, b: String) -> bool:
	return ProjectSettings.globalize_path(b).begins_with(ProjectSettings.globalize_path(a))
