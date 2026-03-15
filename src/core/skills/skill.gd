extends RefCounted
class_name Skill

## Skill - 技能基类
## 所有技能的基类

var skill_name: String = ""
var skill_description: String = ""
var aura_cost: int = 0
var cooldown_turns: int = 0
var current_cooldown: int = 0


func _init(name: String, desc: String, cost: int, cooldown: int = 0) -> void:
	skill_name = name
	skill_description = desc
	aura_cost = cost
	cooldown_turns = cooldown


func can_use(user: Character) -> bool:
	return current_cooldown == 0 and user.current_aura >= aura_cost


func use(user: Character, target = null) -> bool:
	if not can_use(user):
		return false
	
	if not user.consume_aura(aura_cost):
		return false
	
	_apply_effect(user, target)
	current_cooldown = cooldown_turns
	return true


func _apply_effect(user: Character, target) -> void:
	# 子类重写此方法实现具体效果
	pass


func update_cooldown() -> void:
	if current_cooldown > 0:
		current_cooldown -= 1


func get_cooldown_progress() -> float:
	if cooldown_turns == 0:
		return 1.0
	return 1.0 - (float(current_cooldown) / float(cooldown_turns))
