extends Node

## SceneManager - 场景切换管理器
## 处理场景之间的平滑过渡

var current_scene = null


func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)


func change_scene(path: String) -> void:
	call_deferred("_deferred_change_scene", path)


func _deferred_change_scene(path: String) -> void:
	current_scene.free()
	var s = load(path)
	current_scene = s.instantiate()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene
