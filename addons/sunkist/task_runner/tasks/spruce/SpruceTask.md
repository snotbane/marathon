# `SpruceTask`
This task is used to clean up images that may have stray marks or pixels on them, typically, before compiling them using [`FatsheetTask`](/addons/sunkist/task_runner/tasks/fatsheet/FatsheetTask.md).

## Parameters

#### `review_changes`
If enabled, you will be able to compare files that were changed using this window. NOTE: Original files will NOT be updated until you manually approve changes. If disabled, this will overwrite the original file(s), but BEWARE! You may lose data!

#### `source_dir`
All images within this folder (and subfolders) will be processed.


#### `target_dir`
All images processed will be placed in this folder, preserving any subfolders. If unset, will use [`source_dir`](#source_dir).]

> [!TIP]
> It is generally recommended to leave this value blank (defaulting to `source_dir`), so that the files can be manually reviewed and then overwritten. This can help speed up future iterations as unchanged images will not appear in the Review List.


#### `filter_include`
Inclusion filter. Only source names that match this query will be processed. Leave blank for no filter.


#### `filter_exclude`
Exclusion filter. Any source names that match this query will NOT be processed. Leave blank for no filter.


#### `island_opacity`
Pixels with an opacity lower than this value will be considered as not part of any island, and will not contribute to any island's size, and will be discarded along with that island.


#### `island_size`
Pixel islands with a larger rectangular area than this will be included in the final image. Pixel islands with a smaller rectangular area than this will be discarded. Beware! If you have any stray marks that are larger than things like small particles that you intend to be part of the final image, you may need to manually edit these out.


## Using the Main Screen

This will show you how to use each element of the Spruce main screen. Each image can be zoomed to 100% zoom by hovering over it, and you can click the file path to open the image in your system image viewer.

![Spruce Layout](/assets/readme/spruce_layout.png)

### Original Image
This displays the original, unedited image.


### Spruced-up Image
This displays the prospective image which has been cleaned up.


### Diff Bitmap
This displays a bitmap showing where pixels were removed, to help distinguish them. Black areas were unaltered; white islands were removed.

### Review List
This shows a list of all images that were processed and altered. (Unaltered images will not show up here.) Clicking on an item will display it in each of the image previews. You can then use the side buttons to:

1. __*Accept Changes*__. Overwrite the Original Image with the Spruced-up Image.
2. __*Manual Review*__. Open all images in the system image viewer for manual review.
3. __*Revert Changes*__. Discard changes and keep the Original Image.

### Review Controls
This contains miscellaneous controls.

1. __*Accept All*__. Accepts changes on ALL images in the Review List.
2. __*Reject All*__. Reverts changes on ALL images in the Review List.
3. __*Diff Bitmap Toggle*__. Shows/hides the Diff Bitmap.
