@tool extends Task

var _wait_time : float = 1.0
@export_range(0.0, 10.0, 0.5, "or_greater") var wait_time : float = 1.0 :
	get: return _wait_time
	set(value):
		if _wait_time == value: return
		_wait_time = value

		_refresh_wait_time()
func _refresh_wait_time() -> void:
	$timer.wait_time = _wait_time
	$v_box_container/contents/center_container/label.text = str(_wait_time)

func _get_progress() -> float:
	return 1.0 - ($timer.time_left / $timer.wait_time)

func _ready() -> void:
	super._ready()

	_refresh_wait_time()

	$timer.timeout.connect(finish.bind(OK))


func _start() -> void:
	$timer.start()


func _abort() -> bool:
	$timer.stop()

	return false

