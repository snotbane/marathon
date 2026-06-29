@tool class_name Stopwatch extends RefCounted

enum {
	MSEC,
	USEC,
}

@export_storage var precision : int

var _playing : bool

var when_started_ticks : int
var when_stopped_ticks : int

var time_elapsed_ticks : int :
	get: return (now_precise if _playing else when_stopped_ticks) - when_started_ticks

var time_elapsed_sec : float :
	get: return float(time_elapsed_ticks) / 1000.0

var now_precise : int :
	get:
		match precision:
			MSEC:	return Time.get_ticks_msec()
			USEC:	return Time.get_ticks_usec()
			_:		return Time.get_ticks_msec()

var time_elapsed_string_auto : String :
	get:
		var total_seconds : int = time_elapsed_ticks / 1000
		var seconds : int = (total_seconds)			% 60
		var minutes : int = (total_seconds / 60)	% 60
		var hours : int = (total_seconds / 3600)

		if hours > 0:
			return "%02d:%02d:%02d" % [hours, minutes, seconds]
		else:
			return "%02d:%02d" % [minutes, seconds]

func _init(__precision__: int = MSEC) -> void:
	precision = __precision__
	when_started_ticks = now_precise
	when_stopped_ticks = now_precise

func start() -> void:
	_playing = true
	when_started_ticks = now_precise

func stop() -> void:
	_playing = false
	when_stopped_ticks = now_precise
