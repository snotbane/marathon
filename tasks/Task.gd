
@tool class_name Task extends Control

enum {
	QUEUED,
	RUNNING,
	ABORTING,
	SUCCEEDED,
	FAILED,
}


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

var _comment : String
@export var comment : String :
	get: return _comment
	set(value):
		if _comment == value: return
		_comment = value
		comment_changed.emit()

func _get_default_comment() -> String:
	return template.name if template else ""

func refresh_comment_if_default() -> void:
	if _comment != _get_default_comment(): return
	_refresh_comment_if_default_deferred.call_deferred()
func _refresh_comment_if_default_deferred() -> void:
	comment = _get_default_comment()


@export_tool_button("Start") var start_tool_button := start
@export_tool_button("Stop") var abort_tool_button := abort

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

var running : bool :
	get: return _status == RUNNING or _status == ABORTING
	set(value):
		if running == value: return
		if value:	start()
		else:		abort()

var progress : float :
	get: return clampf(inverse_lerp(progress_bar.min_value, progress_bar.max_value, progress_bar.value), 0.0, 1.0)


func _ready() -> void:
	if comment.is_empty():
		comment = _get_default_comment()

	visibility_changed.connect(try_inspect)

	TaskTree.inst.add_task(self)


func _process(delta: float) -> void:
	if not running: return

	time_elapsed_label.text = stopwatch.time_elapsed_string_auto

	_process_running(delta)
func _process_running(delta: float) -> void: pass




func try_inspect() -> void:
	if not visible: return

	EditorInterface.edit_node(self)


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
	finished.emit(code)


func reset() -> void:
	status = QUEUED


func save_args() -> Dictionary:
	var result := Dictionary()
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
