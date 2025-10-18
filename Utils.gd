class_name Utils

static func get_duration_string(msec: int) -> String:
	var total_seconds : int = msec / 1000
	var seconds : int = total_seconds % 60
	var minutes : int = total_seconds / 60
	var hours : int = total_seconds / 3600

	if hours > 0:
		return "%02d:%02d:%02d" % [hours, minutes, seconds]
	else:
		return "%02d:%02d" % [minutes, seconds]

static func get_duration_string_since(when_msec: int) -> String:
	return get_duration_string(Time.get_ticks_msec() - when_msec)
