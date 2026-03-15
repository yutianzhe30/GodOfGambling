extends RefCounted
class_name Item

## Item - 道具基类
## 所有道具的基类

var item_name: String = ""
var item_description: String = ""
var max_stack: int = 99


func _init(name: String, desc: String, stack: int = 99) -> void:
	item_name = name
	item_description = desc
	max_stack = stack


func use(user: Character) -> bool:
	_apply_effect(user)
	return true


func _apply_effect(user: Character) -> void:
	# 子类重写此方法实现具体效果
	pass
