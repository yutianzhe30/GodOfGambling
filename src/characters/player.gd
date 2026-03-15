extends Character
class_name Player

## Player - 玩家角色

signal skill_used(skill_name: String)
signal item_used(item_name: String)

# 玩家可用的技能
var available_skills: Array[String] = []

# 道具背包
var inventory: Dictionary = {}


func _ready():
	character_name = GameManager.player_data.player_name if GameManager.player_data else "高进"
	max_aura = GameManager.player_data.aura_max if GameManager.player_data else 100
	current_aura = GameManager.player_data.aura_current if GameManager.player_data else 100


func unlock_skill(skill_name: String) -> void:
	if not available_skills.has(skill_name):
		available_skills.append(skill_name)


func has_skill(skill_name: String) -> bool:
	return available_skills.has(skill_name)


func use_skill(skill_name: String) -> bool:
	if not has_skill(skill_name):
		return false
	
	# TODO: 检查气场消耗并执行技能效果
	skill_used.emit(skill_name)
	return true


func add_item(item_name: String, quantity: int = 1) -> void:
	inventory[item_name] = inventory.get(item_name, 0) + quantity


func use_item(item_name: String) -> bool:
	if inventory.get(item_name, 0) <= 0:
		return false
	
	inventory[item_name] -= 1
	
	# TODO: 执行道具效果
	match item_name:
		"chocolate":
			restore_aura(30)
	
	item_used.emit(item_name)
	return true
