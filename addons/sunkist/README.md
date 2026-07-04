# Marathon Task Runner

Marathon comes with two separate plugins that are frequently used together.
Use this table of contents to navigate to different sections of the documentation.

## Plugins

- [Task Runner](/addons/sunkist/task_runner/TaskRunner.md)
- [Fatsheet Importer](/addons/sunkist/fatsheet_importer/FatsheetImporter.md)

## Tasks

- [Spruce](/addons/sunkist/task_runner/tasks/spruce/SpruceTask.md)
- [Laigter](/addons/sunkist/task_runner/tasks/laigter/LaigterTask.md)
- [Fatsheet](/addons/sunkist/task_runner/tasks/fatsheet/FatsheetTask.md)
- [OptiPNG](/addons/sunkist/task_runner/tasks/optipng/OptiPngTask.md)


# Quickstart

1. Install this addon to `res://addons/marathon_task_runner`

2. Enable the plugins in __Project Settings__:
	- `Marathon :: Task Runner`
	- `Marathon :: Fatsheet Importer`

3. Open the new `Tasks` plugin window (in the header bar).

4. Click the `Settings` button to open the Task Runner settings in the Inspector.

5. In the Inspector, click the `Install Python Venv` button. This will install a `python3` virtual environment inside the addon folder.
	- Consider adding `.venv` to your project's `.gitignore`.

6. Take a look at the [Task Runner](/addons/sunkist/task_runner/TaskRunner.md) documentation to get started!
