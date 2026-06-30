# Marathon Task Runner

Marathon comes with two separate plugins that are frequently used together.
Use this table of contents to navigate to different sections of the documentation.

## Plugins

- [Task Runner](/addons/marathon_task_runner/task_runner/TaskRunner.md)
- [Fatlas Importer](/addons/marathon_task_runner/fatlas_importer/FatlasImporter.md)

## Tasks

- [Spruce](/addons/marathon_task_runner/task_runner/tasks/spruce/SpruceTask.md)
- [Laigter](/addons/marathon_task_runner/task_runner/tasks/laigter/LaigterTask.md)
- [Fatlas](/addons/marathon_task_runner/task_runner/tasks/fatlas/FatlasTask.md)
- [OptiPNG](/addons/marathon_task_runner/task_runner/tasks/optipng/OptiPngTask.md)


# Quickstart

1. Install this addon to `res://addons/marathon_task_runner`

2. Enable the plugins in __Project Settings__:
	- `Marathon :: Task Runner`
	- `Marathon :: Fatlas Importer`

3. Open the new `Tasks` plugin window (in the header bar).

4. Click the `Settings` button to open the Task Runner settings in the Inspector.

5. In the Inspector, click the `Install Python Venv` button. This will install a `python3` virtual environment inside the addon folder.
	- Consider adding `.venv` to your project's `.gitignore`.

6. Take a look at the [Task Runner](/addons/marathon_task_runner/task_runner/TaskRunner.md) documentation to get started!
