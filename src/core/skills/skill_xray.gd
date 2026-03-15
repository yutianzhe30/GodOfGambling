extends Skill
class_name SkillXRay

## SkillXRay - 透视眼
## 看穿对手的隐藏牌

var reveal_duration: float = 3.0
var _revealed_card = null
var _target: Character = null
var _is_active: bool = false


func _init() -> void:
	super._init("透视眼", "看穿对手的手牌", 30, 2)


func _apply_effect(user: Character, target) -> void:
	if target == null or not target is Character:
		return
	
	_target = target
	# 尝试获取目标的底牌
	if target.get_hidden_card() != null:
		_revealed_card = target.get_hidden_card()
		_is_active = true
		print("透视眼已激活！看到底牌: %s" % _revealed_card.get_display_name())


func is_active() -> bool:
	return _is_active


func get_revealed_card():
	return _revealed_card


func deactivate() -> void:
	_is_active = false
	_revealed_card = null
	_target = null
