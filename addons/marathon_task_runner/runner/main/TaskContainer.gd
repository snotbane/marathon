@tool class_name TaskContainer extends TabContainer

static var inst : TaskContainer

var current_task : Task :
	get: return get_child(current_tab) if current_tab != -1 else null
	set(value):
		assert(value == null or value.get_parent() == self)

		if value == null:
			current_tab = -1
		else:
			value.visible = true


func _ready() -> void:
	if MarathonUtils.is_node_in_editor(self): return

	inst = self
