# `LaigterTask`
This task generates extra image files (/.docs/laigter). Laigter has its own queueing system, but the GUI can slow down with more images and larger images. Additionally, this will preserve transparent pixels in normal maps, which Laigter does not do.


#### `laigter_path`
This parameter must be set to the location of [Laigter](/.docs/laigter)'s command line path on this local machine. This is a static variable, so it only needs to be set once and it will not change for all instances of this task.


#### `preset_path`
This parameter must be set to a valid preset file. This file can be created within the [Laigter](/.docs/laigter) GUI application.


#### `source_dir`
All images within this folder (and subfolders) will be processed.


#### `target_dir`
This is where the resulting images will be placed into, preserving subfolders. If left blank, [`source_dir`](#source_dir) will be used.


#### `target_suffix`
Suffix to append to the target file to distinguish it from the source.


#### `filter_include`
Inclusion filter. Only source names that match this query will be processed. Leave blank for no filter.


#### `filter_exclude`
Exclusion filter. Any source names that match this query will NOT be processed. Leave blank for no filter.

#### `overwrite`
If enabled, this will overwrite any target files that already exist. If disabled, this will NOT process any sources which already have a target file present at the specified target and with the specified [`target_suffix`](#target_suffix).
