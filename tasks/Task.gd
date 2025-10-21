
@tool class_name Task extends Control

enum {
	QUEUED,
	INVALID,
	RUNNING,
	ABORTING,
	SUCCEEDED,
	FAILED,
}


const PLAY_ICON : Texture2D = preload("uid://clac2ow8ahs4r")
const STOP_ICON : Texture2D = preload("uid://cu07nwotdlchh")
const RESET_ICON : Texture2D = preload("uid://ct7p1qh0ybn05")
const OPEN_ICON : Texture2D = preload("uid://dtxcom0expqpo")
const COPY_ICON : Texture2D = preload("uid://cqjx2fyt0kmb3")
const REMOVE_ICON : Texture2D = preload("uid://cmhgkxhl65v0q")


static func get_source_target_diff_path(source: String, target: String) -> String:
	if source == "": return target

	var result : String
	while source != "":
		var source_snip := source.substr(source.rfind("/"))
		var target_snip := target.substr(target.rfind("/"))

		result = target_snip.path_join(result) if result else target_snip

		if source_snip == target_snip: break

		source = source.substr(0, source.rfind("/"))
		target = target.substr(0, target.rfind("/"))

	return result

signal comment_changed
signal status_changed
signal progress_changed

signal started
signal abort_requested
signal finished(code: int)


@export_storage var template : TaskTemplate


@onready var stopwatch := Stopwatch.new()
@onready var progress_bar : ProgressBar = $v_box_container/results/progress_bar
@onready var time_elapsed_label : Label = $v_box_container/results/progress_bar/margin_container/time_elapsed
@onready var items_completed_label : Label = $v_box_container/results/progress_bar/margin_container/stats/items_completed

var _comment : String = ""
## Custom comment to label this [Task]. Resets to a default value determined by the type of [Task] being called.
@export var comment : String = "" :
	get: return _comment
	set(value):
		if _comment == value: return
		_comment = value if value else _get_default_comment()
		comment_changed.emit()

func _get_default_comment() -> String:
	return template.name if template else ""

func refresh_comment_if_default() -> void:
	if not _comment.is_empty() and _comment != _get_default_comment(): return
	_refresh_comment_if_default_deferred.call_deferred()
func _refresh_comment_if_default_deferred() -> void:
	comment = _get_default_comment()


var _status : int = QUEUED
var status : int = QUEUED :
	get: return _status
	set(value):
		if _status == value: return
		_status = value

		match _status:
			QUEUED, RUNNING:	progress_bar.value = 0.0
			SUCCEEDED:			progress_bar.value = 1.0

		match _status:
			RUNNING: 			stopwatch.start()
			SUCCEEDED, FAILED:	stopwatch.stop()

		status_changed.emit()

var _errors : PackedStringArray
var error_tooltip_text : String :
	get:
		var result := String()
		for err in _errors :
			result += "\n" + err
		return result.substr(1)
var arguments_valid : bool :
	get: return _errors.is_empty()


var running : bool :
	get: return _status == RUNNING or _status == ABORTING
	set(value):
		if running == value: return
		if value:	start()
		else:		abort()

var progress : float :
	get: return clampf(inverse_lerp(progress_bar.min_value, progress_bar.max_value, progress_bar.value), 0.0, 1.0)


func _ready() -> void:
	if Utils.is_node_in_editor(self): return

	comment = _get_default_comment()

	visibility_changed.connect(try_inspect)

	TaskTree.inst.add_task(self)

	validate_args()


func _process(delta: float) -> void:
	if not running: return

	time_elapsed_label.text = stopwatch.time_elapsed_string_auto

	_process_running(delta)
func _process_running(delta: float) -> void: pass




func try_inspect() -> void:
	if visible:
		EditorInterface.edit_node(self)
	elif EditorInterface.get_inspector().get_edited_object() == self:
		EditorInterface.edit_node(null)


func run() -> void:
	start()
	await finished


func start() -> void:
	if running: return
	status = RUNNING

	_start()
	started.emit()
func _start() -> void: pass


func abort(__reset__: bool = false) :
	if not running: return

	status = ABORTING
	abort_requested.emit()

	if _abort():	await finished
	else:			finish(-1)

	if __reset__: reset()
func _abort() -> bool:
	return false


func finish(code: int) -> void:
	if not running: return

	status = SUCCEEDED if code == OK else FAILED
	_finish(code)
	finished.emit(code)
func _finish(code: int) -> void: pass


func reset() -> void:
	status = QUEUED
	_reset()
func _reset() -> void: pass


func validate_args() -> void:
	_errors.clear()
	_validate_args()

	match status:
		QUEUED, INVALID:
			status = QUEUED if arguments_valid else INVALID
			status_changed.emit()

func _validate_args() -> void: pass

func validate_file_path(path: String, required: bool, var_name: String) -> void:
	if path.is_empty() and required:
		_errors.push_back("Filepath '%s' cannot be blank." % var_name)
	elif not FileAccess.file_exists(path):
		_errors.push_back("Filepath '%s' does not exist." % var_name)

func validate_dir_path(path: String, required: bool, var_name: String) -> void:
	if path.is_empty() and required:
		_errors.push_back("Directory '%s' cannot be blank." % var_name)
	elif not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(path)):
		_errors.push_back("Directory '%s' does not exist." % var_name)

func validate_regex_string(rx: String, required: bool, var_name: String) -> void:
	if rx.is_empty() and required:
		_errors.push_back("Regex '%s' cannot be blank." % var_name)
	elif not RegEx.create_from_string(rx).is_valid():
		_errors.push_back("RegEx '%s' is not valid." % var_name)

func validate_non_empty_string(s: String, var_name: String) -> void:
	if s.is_empty():
		_errors.push_back("'%s' cannot be blank." % var_name)

func validate_dir_contains(dir: String, path: String, require_inside: bool) -> void:
	if Utils.is_folder_inside_other(dir, path) != require_inside:
		_errors.push_back("The file or folder '%s' must %sbe contained inside directory '%s'." % [path, "" if require_inside else "NOT ", dir])


func save_args() -> Dictionary:
	var result := {
		&"template_uid": ResourceUID.id_to_text(ResourceLoader.get_resource_uid(template.resource_path))
	}
	_save_args(result)
	return result
func _save_args(result: Dictionary) -> void: pass

func load_args(data: Dictionary) -> void:
	_load_args(data)
func _load_args(data: Dictionary) -> void: pass




func _on_comment_editor_text_changed(new_text: String) -> void:
	_comment = new_text
	comment_changed.emit()

func _on_progress_bar_value_changed() -> void:
	progress_changed.emit()
