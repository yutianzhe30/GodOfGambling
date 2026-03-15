extends Skill
class_name SkillSwitch

## SkillSwitch - 偷龙转凤
## 将手牌中的一张牌与牌堆顶的牌交换


func _init() -> void:
	super._init("偷龙转凤", "与牌堆中的牌交换", 50, 3)


func _apply_effect(user: Character, target) -> void:
	# 需要PokerGame提供牌堆访问
	print("偷龙转凤已激活！选择一张手牌进行交换")
