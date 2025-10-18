
@tool class_name PythonTask extends Task

const ABORT_KEY := "stop"

static var BUS_DIR_ACCESS : DirAccess

static var TEMP_DIR_PATH : String :
	get: return ProjectSettings.globalize_path("user://tmp/")

static var PYTHON_PATH : String :
	get: return "python3" # TODO: replace with global user settings

static func _static_init() -> void:
	BUS_DIR_ACCESS = DirAccess.open("user://")


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


@export var identifier : StringName = &"program"
@export var print_output : bool = false
@export_file("*.py") var python_script_path : String
@export var progress_elements : Array[Control]


var bus : ConfigFile
var bus_path : String
var thread : Thread


func _get_default_comment() -> String:
	return "Python task: " + super._get_default_comment()


func get_python_arguments() -> PackedStringArray:
	var result : PackedStringArray
	result.push_back(PythonTask.localize_script_path(python_script_path))
	result.push_back(ProjectSettings.globalize_path(bus_path))
	for arg in save_args():
		result.push_back(PythonTask.value_as_python_argument(arg))
	if print_output:
		print("%s args: %s" % [self.identifier, result])
	return result


func _enter_tree() -> void:
	bus_path = "%s%s_%s.cfg" % [
		BUS_DIR_ACCESS.get_current_dir(),
		name,
		get_instance_id()
	]

func _exit_tree() -> void:
	BUS_DIR_ACCESS.remove(bus_path)


func _ready() -> void:
	super._ready()

	thread = Thread.new()

func _process_running(delta: float) -> void:
	super._process_running(delta)

	if thread.is_alive():
		pass
	else:
		_thread_stopped()


func _thread_stopped() -> void:
	var code := thread.wait_to_finish()

	refresh_elements()
	BUS_DIR_ACCESS.remove(bus_path)
	bus = null

	finish(code)


func _start() -> void:
	bus = ConfigFile.new()
	for element in progress_elements:
		if element.get(&"value") == null: continue

		bus.set_value("output", element.name, element.value)
	bus.save(bus_path)

	thread.start(python.bind(PYTHON_PATH, get_python_arguments()))

func _abort() -> bool:
	bus.set_value("input", ABORT_KEY, true)
	bus.save(bus_path)

	return true


func python(python_path: String, args: PackedStringArray) -> int:
	var output : Array
	var result : int = OS.execute(python_path, args, output, print_output)
	if print_output: for e in output: print(e)
	return result


func refresh_elements() -> void:
	bus.load(bus_path)
	for element in progress_elements:
		if element.get(&"value") == null: continue
		element.value = bus.get_value("output", element.name)
# 	_refresh_elements()
# func _refresh_elements() -> void:
# 	pass
