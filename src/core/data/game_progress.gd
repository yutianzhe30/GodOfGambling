extends Resource
class_name GameProgress

## GameProgress - 游戏进度
## 存储关卡进度和故事状态

@export var current_level: int = 1
@export var levels_completed: Array[int] = []
@export var story_flags: Dictionary = {}

# 各关卡数据
@export var level_data: Dictionary = {
	1: {"completed": false, "best_score": 0},
	2: {"completed": false, "best_score": 0},
	3: {"completed": false, "best_score": 0}
}


func reset() -> void:
	current_level = 1
	levels_completed.clear()
	story_flags.clear()
	for level in level_data.keys():
		level_data[level] = {"completed": false, "best_score": 0}


func complete_level(level: int, score: int) -> void:
	if not levels_completed.has(level):
		levels_completed.append(level)
	
	level_data[level]["completed"] = true
	if score > level_data[level]["best_score"]:
		level_data[level]["best_score"] = score
	
	if level >= current_level:
		current_level = level + 1


func set_story_flag(flag_name: String, value: bool = true) -> void:
	story_flags[flag_name] = value


func get_story_flag(flag_name: String) -> bool:
	return story_flags.get(flag_name, false)
