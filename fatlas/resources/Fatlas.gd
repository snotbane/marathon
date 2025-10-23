## Manages Fatlas data files and generates/updates sub-resources, including multiple [OffsetAtlasTexture] and [CompositeTexture2D].
@tool class_name Fatlas extends Resource

const TEXTURE_FOLDER_NAME := "textures"
const COMPOSITE_FOLDER_NAME := "compo"
const ATLAS_FOLDER_NAME := "atlas"

@export_storage var json_path : String

func refresh_resources() -> void:
	var base_folder := json_path.get_base_dir()
	var texture_folder := base_folder.path_join(TEXTURE_FOLDER_NAME)
	var compo_folder := base_folder.path_join(COMPOSITE_FOLDER_NAME)
	var atlas_folder := base_folder.path_join(ATLAS_FOLDER_NAME)

	if not DirAccess.dir_exists_absolute(texture_folder):
		DirAccess.make_dir_recursive_absolute(texture_folder)
	if not DirAccess.dir_exists_absolute(atlas_folder):
		DirAccess.make_dir_recursive_absolute(atlas_folder)
	if not DirAccess.dir_exists_absolute(compo_folder):
		DirAccess.make_dir_recursive_absolute(compo_folder)

	var existing_atlases := MarathonUtils.get_paths_in_folder(atlas_folder)
	var existing_compos := MarathonUtils.get_paths_in_folder(compo_folder)

	var images : Array[Texture2D]
	for i in MarathonUtils.get_paths_in_folder(texture_folder, RegEx.create_from_string(".png$")):
		images.push_back(load(i))

	# do_destroy(false)
	var fresh_paths : PackedStringArray = []
	var created_paths : Dictionary

	var file := FileAccess.open(json_path, FileAccess.READ)
	if file == null:
		printerr("Fatlas: null file at path '%s'" % json_path)
		return

	var data : Dictionary = JSON.parse_string(file.get_as_text())

	var texture : Dictionary = data[ATLAS_FOLDER_NAME]
	for k in texture.keys():
		var mega_texture : Texture2D = load(texture_folder.path_join(k))
		for subimage_name in texture[k].keys():
			var coord : Array = texture[k][subimage_name]
			var source_offset := Vector2i(coord[2], coord[3])
			var target_region := Rect2i(coord[0], coord[1], coord[4], coord[5])

			var atlas_path : String = atlas_folder.path_join(subimage_name + ".tres")
			var atlas : OffsetAtlasTexture
			if FileAccess.file_exists(atlas_path):
				atlas = load(atlas_path)
			else:
				atlas = OffsetAtlasTexture.new()

			atlas.name = subimage_name
			atlas.atlas = mega_texture
			atlas.offset = Vector2i(source_offset)
			atlas.region = Rect2(target_region)
			atlas.filter_clip = true

			ResourceSaver.save(atlas, atlas_path)
			created_paths[atlas.name] = atlas_path

	fresh_paths.append_array(created_paths.values())

	var compo : Dictionary = data[COMPOSITE_FOLDER_NAME]
	for base_name in compo.keys():
		var base : Dictionary = compo[base_name]

		var compo_path : String = compo_folder.path_join(base_name + ".tres")
		var composite : CompositeTexture2D
		if FileAccess.file_exists(compo_path):
			composite = load(compo_path)
			composite.maps.clear()
		else:
			composite = CompositeTexture2D.new()

		for suffix in base.keys():
			var link : String = base[suffix]
			composite.maps[suffix] = load(created_paths[link])

		ResourceSaver.save(composite, compo_path)
		fresh_paths.append(compo_path)

		# EditorInterface.get_resource_previewer().queue_edited_resource_preview(composite, composite, "bar", null)
		# EditorInterface.get_resource_previewer().queue_resource_preview(composite_path, composite, "bar", null)
		# EditorInterface.get_resource_previewer().queue_resource_preview(composite_path, composite, "bar", null)

	var dir := DirAccess.open(atlas_folder)
	for path in existing_atlases: if path not in fresh_paths:
		dir.remove(path)
	dir = DirAccess.open(compo_folder)
	for path in existing_compos: if path not in fresh_paths:
		dir.remove(path)
