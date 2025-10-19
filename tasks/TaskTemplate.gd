
@tool class_name TaskTemplate extends Resource

const META_NAME := &"task_template"

@export var name : String
@export var icon : Texture2D
@export var _scene_uid : String
var scene : PackedScene :
	get: return load(_scene_uid)


func create_button() -> Button:
	var result := Button.new()

	result.text = name
	result.icon = icon
	result.pressed.connect(create_task)

	return result


func create_task(focus: bool = true) -> Task:
	var result : Task = scene.instantiate()
	result.template = self

	TaskContainer.inst.add_child(result)
	result.visible = focus

	return result

