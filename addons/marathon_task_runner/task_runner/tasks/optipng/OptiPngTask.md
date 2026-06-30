# `OptiPNGTask`
This task losslessly compresses `.png` images in bulk, using [OptiPNG](https://optipng.sourceforge.net/). This is a very slow operation, but can greatly reduce the size of project files. [OptiPNG](https://optipng.sourceforge.net/) is a 3rd-party program, so it must first be installed on your device in order for the task to work.


#### `optipng_path`
This parameter must be set to the location of [OptiPNG](https://optipng.sourceforge.net/) on this local machine. This is a static variable, so it only needs to be set once and it will not change for all instances of this task.


#### `target_dir`
This is the target directory. All `.png` files within this folder (and subfolders) will be processed by [OptiPNG](https://optipng.sourceforge.net/). This will overwrite the files, but no data will be lost.
