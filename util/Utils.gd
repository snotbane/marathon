class_name Utils

static func get_project_preferred_path(path: String) -> String:
	var project_root_global := ProjectSettings.globalize_path("res://")
	project_root_global = project_root_global.substr(0, project_root_global.length() - 1)
	var path_global := ProjectSettings.globalize_path(path)
	var path_belongs_to_project := path_global.begins_with(project_root_global)
	return ("res://" + path_global.substr(project_root_global.length())) if path_belongs_to_project else path_global
