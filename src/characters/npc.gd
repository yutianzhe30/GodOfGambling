extends Character
class_name NPC

## NPC - NPC角色
## 游戏中的对手角色

enum PersonalityType {
	AGGRESSIVE,    # 激进型
	CONSERVATIVE,  # 保守型
	BLUFFER,       # 偷鸡型
	BALANCED       # 平衡型
}

@export var personality: PersonalityType = PersonalityType.BALANCED
@export var difficulty: int = 1  # 1-5

# AI控制器
var ai_controller: AIBase = null


func _ready():
	_setup_ai()


func _setup_ai() -> void:
	match personality:
		PersonalityType.AGGRESSIVE:
			ai_controller = AIAggressive.new()
		PersonalityType.CONSERVATIVE:
			ai_controller = AIConservative.new()
		PersonalityType.BLUFFER:
			ai_controller = AIBluffer.new()
		_:
			ai_controller = AIBase.new()
	
	ai_controller.set_npc(self)


func make_decision(game_state: Dictionary) -> Dictionary:
	return ai_controller.make_decision(game_state)


func set_personality(type: PersonalityType) -> void:
	personality = type
	_setup_ai()


func get_personality_name() -> String:
	match personality:
		PersonalityType.AGGRESSIVE: return "激进型"
		PersonalityType.CONSERVATIVE: return "保守型"
		PersonalityType.BLUFFER: return "偷鸡型"
		PersonalityType.BALANCED: return "平衡型"
	return "未知"
