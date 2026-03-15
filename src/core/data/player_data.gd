extends Resource
class_name PlayerData

## PlayerData - 玩家数据
## 存储玩家的属性和状态

@export var player_name: String = "高进"
@export var level: int = 1
@export var experience: int = 0
@export var aura_max: int = 100
@export var aura_current: int = 100

# 技能解锁状态
@export var skills_unlocked: Dictionary = {
	"xray_vision": false,
	"card_switch": false,
	"mind_pressure": false
}

# 道具持有
@export var inventory: Dictionary = {}

# 金钱
@export var money: int = 1000


func add_experience(amount: int) -> void:
	experience += amount
	_check_level_up()


func _check_level_up() -> void:
	var required_exp = level * 100
	if experience >= required_exp:
		experience -= required_exp
		level += 1
		_level_up_rewards()


func _level_up_rewards() -> void:
	aura_max += 10
	aura_current = aura_max
