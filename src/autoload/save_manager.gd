extends Node

## SaveManager - 存档管理器
## 处理游戏存档的保存和加载

const SAVE_PATH = "user://savegame.dat"


func save_game(data: Dictionary) -> bool:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open save file for writing")
		return false
	
	var json = JSON.stringify(data)
	file.store_string(json)
	file.close()
	return true


func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Failed to open save file for reading")
		return {}
	
	var json = file.get_as_text()
	file.close()
	
	var data = JSON.parse_string(json)
	if data == null:
		push_error("Failed to parse save file")
		return {}
	
	return data


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
