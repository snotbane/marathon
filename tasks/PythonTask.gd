
@tool class_name PythonTask extends Task

const ABORT_KEY := "stop"

static var TEMP_DIR_PATH : String :
	get: return ProjectSettings.globalize_path("user://tmp/")


static func localize_script_path(path: String) -> String:
	if OS.has_feature("editor"):
		return ProjectSettings.globalize_path(path)
	else:
		var result : String = path.substr(path.rfind("/") + 1)
		return OS.get_executable_path().get_base_dir().path_join("python").path_join(result)


static func value_as_python_argument(value: Variant) -> String:
	if value is float and fmod(value, 1.0) == 0.0:
		return str(int(value))
	return str(value)


@export var print_output : bool = true
@export_file("*.py") var python_script_path : String

var bus_dir : DirAccess
var bus : ConfigFile
var bus_path : String
var thread : Thread


func _get_default_comment() -> String:
	return "Python task: " + super._get_default_comment()


func get_python_arguments() -> PackedStringArray:
	var result : PackedStringArray
	result.push_back(PythonTask.localize_script_path(python_script_path))
	result.push_back(ProjectSettings.globalize_path(bus_path))
	for arg in save_args().values():
		result.push_back(PythonTask.value_as_python_argument(arg))
	return result

func _exit_tree() -> void:
	bus_dir.remove(bus_path)


func _ready() -> void:
	super._ready()

	bus_dir = DirAccess.open("user://")
	bus_path = "%s%s_%s.cfg" % [
		bus_dir.get_current_dir(),
		name,
		get_instance_id()
	]

	thread = Thread.new()

func _process_running(delta: float) -> void:
	super._process_running(delta)

	if thread.is_alive():
		refresh_elements()
	else:
		_thread_stopped()


func _thread_stopped() -> void:
	var code := thread.wait_to_finish()

	refresh_elements()
	bus_dir.remove(bus_path)
	bus = null

	finish(code)


func _start() -> void:
	bus = ConfigFile.new()

	_bus_init()
	bus.save(bus_path)

	var code : int = thread.start(python.bind(MarathonGlobalSettings.inst.python_path_global, get_python_arguments()))
	if code == OK: return

	finish(code)
func _bus_init() -> void: pass

func _abort() -> bool:
	bus.set_value("input", ABORT_KEY, true)
	bus.save(bus_path)

	return true


func python(exe_thread_safe: String, args: PackedStringArray) -> int:
	if print_output:
		print("%s args: %s" % [template.name, args])

	var output : Array
	var result : int = OS.execute(exe_thread_safe, args, output, print_output)
	if print_output: for e in output:
		if result == OK:	print(e)
		else:				printerr(e)
	return result


func refresh_elements() -> void:
	bus.load(bus_path)
	_bus_poll()
func _bus_poll() -> void:
	progress_bar.value = bus.get_value("output", "progress", 0)
	progress_bar.max_value = bus.get_value("output", "progress_max", 1)

	items_completed_label.text = "%s of %s completed" % [ int(progress_bar.value), int(progress_bar.max_value) ]

	progress_changed.emit()
