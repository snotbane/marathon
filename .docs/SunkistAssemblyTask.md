# `SunkistAssemblyTask`
This task compiles many images into fewer or one [spritesheet](/.docs/Texture_atlas), to assist with resource management.


> [!TIP]
> The positions of each image in the spritesheet(/.docs/README.md#sunkist-plugin) documentation.

## How to Use

This guide will show you how to get from loose files to a fully rendered 3D sprite.

### 1. Setting Up the Task

Setting up files for the Sunkist Assembly Task relies heavily on the naming scheme of the files to be processed. This tutorial assumes you already have a series of images in which:

- All are `.png` files
- All are located inside of a single directory tree, the root of which will be your __*Source Folder*__.
- All are [cleaned up](/.docs/SpruceTask.md) and ready to be packed
- Each __*image canvas*__ has identical dimensions
- Each __*sprite bounding box*__ for separate material components (same name, different suffix) has identical dimensions
- Have a file name that ends with any of the following suffixes:
	- `-r-a` — Albedo __[ REQUIRED ]__
	- `-l-a` — Albedo (Backface)
	- `-r-e` — Emission
	- `-l-e` — Emission (Backface)
	- `-r-n` — Normal
	- `-l-n` — Normal (Backface)
	- `-r-m` — Custom
	- `-l-m` — Custom (Backface)

Create a new Assembly task and select it so it shows up in the Inspector, then set your source and target folders.

> [!NOTE]
>
> In this example, we are using source files which are already located the Godot project, for simplicity. However in practice, it's ideal to keep the __*Source Folder*__ outside the project entirely, since the source images won't be used again.
>
> If you run the task again later in the same location and it will overwrite the previous results.)This is often desired, but may not be in some cases.

![Tutorial00](/.docs/sunkist_tutorial_00.png)

### 2. Running the Task

Click the run button on the task to start assembling `SunkistSheet`s. You should see each image display in the preview window briefly as it is processed. If you have lots of files, it will start fast and become slower.

After running the Task, you should see a grid displaying each of the __*Result Images*__. In the __*Target Folder*__, you should now see the following:

- A folder `sheets`, which contains the raw `.png` files which were assembled.
- A folder `sprites`, which contains a copy of each image in the __*Source Folder*__, as an `AtlasTexture` belonging to one of the images in `sheets`.
- A folder `sunkist`, which contains `SunkistTexture`s based on the source images. These are the textures you will want to use when creating Scenes or any `SpriteFrames` Resources.
- A file with the extension `.sun`, which contains all of the data to assemble and manage the above.

> [!IMPORTANT]
> You may need to refresh the FileSystem and open any created `.sun` files in order for all resources to appear properly. This is a known issue.

![Tutorial01](/.docs/sunkist_tutorial_01.png)



### 3. Previewing a `SunkistTexture`

To preview a `SunkistTexture`, simply open it in the FileSystem. (Make sure the Sunkist plugin is enabled.)
- The left panel (green) will display the `AtlasTexture`s which compose the `SunkistTexture`.
- The right panel (blue) will display a 3D render of this `SunkistTexture`.

![Tutorial02](/.docs/sunkist_tutorial_02.png)

### 4. Creating a scene using `Sunkist3D`

See [Sunkist Nodes](/.docs/README.md#nodes) on how to structure a scene using Sunkist resources.

![Tutorial03](/.docs/sunkist_tutorial_03.png)

## Parameters

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
> If you are noticing huge portions of empty space in your resulting spritesheets, it is likely that there are stray pixels that are extending the bounding box of the sprite. Consider using [Spruce](/.docs/SpruceTask.md) to remove these.


#### `island_margin`
The space between sprites and image bounds in the final spritesheet(s).
