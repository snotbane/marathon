# `FatlasTask`
This task compiles many images into fewer or one [spritesheet](https://en.wikipedia.org/wiki/Texture_atlas), to assist with resource management. This operation has a complex setup but is extremely powerful, especially when used with the Fatlas Importer plugin (the plugin is NOT required to use this `Task`).

In the destination folder, this will create:

- A `textures` folder consisting of spritesheets.
- An `atlas` folder consisting of [`AtlasTexture`](https://docs.godotengine.org/en/stable/classes/class_atlastexture.html)s based on all source images. Use these for simple sprite sheets.
- A `compo` folder consisting of [`CompositeTexture2D`]()s. Use these for complex spritesheets.
- A `.fat` file which contains metadata for each [`CompositeTexture2D`]().

> [!IMPORTANT]
> You may need to refresh the FileSystem and open any created `.fat` files in order for all resources to appear properly. This is a known issue.

> [!TIP]
> For more information about how `.fat` files are used, consult the [Fatlas Importer](/addons/marathon_task_runner/fatlas/FatlasImporter.md) documentation.


#### `project_name`
This is the name of the resulting image file(s) and data file.


#### `source_dir`
Source folder to assemble target image(s) from. It is ideal to use a folder outside of the Godot project itself, as you are very likely to use the resulting files instead of the source files.


#### `target_dir`
Target folder in which to place target image(s). This will create multiple subfolders in this location. It is ideal to use a folder inside your Godot project, as you are likely to use them here.


#### `target_size_limit`
The max pixel dimensions (square) a target image can be. If an island cannot be placed without expanding the target image beyond this limit, a new target image will be created.


#### `filter_include`
Inclusion filter. Only source names that match this query will be processed. Leave blank for no filter.


#### `filter_exclude`
Exclusion filter. Any source names that match this query will NOT be processed. Leave blank for no filter.


#### `filter_separate`
File names (excluding extension) matching this regex filter will be separated into different spritesheets. Target files will be named based on this filter.

This is primarily used to keep different kinds of sprites together, such as albedo and normal maps. For example, use `-[a-zA-Z]$` to separate files ending with an alphabetic character, like `-n`, `-o`, `-m`, etc. This is necessary if you have normal maps or similar for matching sprites, since normal map sprite sheets will need to be used as raw data, whereas albedo maps will need to be used as color data.

Default: `^` (This will combine all source images into a single spritesheet, because all file names contain this character sequence.)


#### `island_crop`
If enabled, only the bounding box containing all visible pixels will be included in the final spritesheet(s).
If disabled, include the entire source image.

> [!TIP]
> If you are noticing huge portions of empty space in your resulting spritesheets, it is likely that there are stray pixels that are extending the bounding box of the sprite. Consider using [Spruce](/addons/marathon_task_runner/task_runner/tasks/spruce/SpruceTask.md) to remove these.


#### `island_margin`
The space between sprites and image bounds in the final spritesheet(s).
