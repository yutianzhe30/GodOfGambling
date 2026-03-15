extends Skill
class_name SkillPressure

## SkillPressure - 心理施压
## 降低对手的气场

var aura_reduction: int = 20


func _init() -> void:
	super._init("心理施压", "降低对手气场", 40, 2)


func _apply_effect(user: Character, target: Character) -> void:
	if target == null:
		return
	
	# 降低目标气场
	target.consume_aura(aura_reduction)
	print("心理施压：%s 失去了 %d 点气场" % [target.character_name, aura_reduction])
