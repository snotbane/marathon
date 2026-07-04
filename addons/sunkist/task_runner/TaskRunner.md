# Task Runner
The Sunkist Task Runner creates a plugin window called `Tasks`. This window can be used to run tasks on any files, in bulk. This plugin is NOT required to create or use `SunkistTexture`s.

![Task Runner Layout](/addons/sunkist/.readme/task_runner_layout.png)

The left wing of the screen displays the __*Task Queue*__ and can be resized. The main area of the screen displays the __*Selected Task*__.

### Task Queue Controls
These buttons are used to modify and run `Task`s in the Task Queue. In order from top left to bottom right, they are:

|Button|What it does|
|-|-|
|__*Create New*__|This will clear all tasks in the queue.|
|__*Save*__|This will save the current queue, and prompt you to __*Save As*__ if it is not yet saved. *(Note: The current working queue is automatically saved in a temporary file between editor sessions.)*|
|__*Save As*__|This will save the current queue as a new file.|
|__*Load*__|This will load a queue of tasks from an existing `.json` file, which has been created with __*Save*__, and __*replace the existing*__ queue.|
|__*Append*__|This will load a queue of tasks in an existing `.json` file, and __*append it to the current*__ queue.|
|__*Settings*__|This will open the `TaskRunner` in the Inspector.|
|__*Run/Stop Queue*__|This will run all `Ready` Tasks in order from start to finish, or it will attempt to stop any running Tasks (if started). It will NOT run any `Completed` tasks.|
|__*Reload Queue*__|This will reset all `Completed` or `Failed` tasks so they may be run again.|


### Task Queue
A list of `Task`s to be run in sequence. Clicking on one will display it in the __*Selected Task Window*__, as well as in the Inspector. Its properties and arguments are modified in the Inspector. `Task`s can be dragged and dropped to reorder them.

1. __*Type*__. This is the type of Task that will be run.

2. __*Comment*__. A description of the Task which can be customized.

3. __*Status*__. Indicates if the task is:
	- `Ready` : Ready to be run and has not yet done so.
	- `Invalid` : Not set up properly and cannot be run.
	- `Running` : Currently running.
	- `Stopping` : Attempting to stop running, due to the user telling it to.
	- `Completed` : Completed successfully.
	- `Failed` : Finished, but there was an error (which should display as an error in the console).

4. __*Action*__. Allows the user to:
	- `Run/Stop/Reset` : Manually run this Task only. If the queue is already running, this will start running this item simultaneously. If it is `Running`, this will stop running itself and all others in the queue. If it is `Completed` or `Failed`, this will set it to `Ready`.
	- `Duplicate` : Create a copy of this `Task` and adds it to the end of the queue.
	- `Remove` : Remove this `Task` from the queue (permanent, no warning!).

### Create New Task

A list of buttons that will add a new kind of `Task` to the Task Queue.

### Selected Task Window

This is where a preview of the `Task` selected in the Task Queue will be displayed.

### Selected Task Progress

This displays details about the progress of the `Task`, including:

1. `Run/Stop/Reset` : A shortcut for handling execution of this `Task`. Identical to the `Run/Stop/Reset` button for this `Task` in the Task Queue.
2. __*Elapsed Time*__. Displays the amount of time that this `Task` has been running for, or how long it took to finish.
3. __*Percent Complete*__. Displays the percentage completed.
4. __*Items Complete*__. Displays the number of items completed, out of the total number items.

<!-- # How To Create a Custom Task
 -->


# Base Objects

## `Task`

The base class for any task that can be run and saved in the task runner.

#### `comment`

This parameter is a custom comment to help you identify it in the task list. If unset, it will be automatically depending on the specific task.

## `PythonTask`

The base class for any `Task` that utilizes a Python script.

#### `python_venv_path`

This parameter is the location of the desired `python3` environment. You can use an environment already on your system, or use the [`Install Python Venv`](#install-python-venv) button to create one at this location.

#### `Install Python Venv`

This button will install a `python3` virtual environment to the path located at [`python_venv_path`](#python_venv_path).
