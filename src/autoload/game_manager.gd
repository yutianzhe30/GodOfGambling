extends Node

## GameManager - 游戏主管理器
## 全局自动加载单例，管理游戏全局状态

# 游戏状态枚举
enum GameState {
	MAIN_MENU,
	PLAYING,
	PAUSED,
	GAME_OVER
}

# 当前游戏状态
var current_state: GameState = GameState.MAIN_MENU

# 玩家数据
var player_data: PlayerData = null

# 游戏进度
var game_progress: GameProgress = null


func _ready():
	print("GameManager initialized")
	_load_player_data()


func _load_player_data() -> void:
	# TODO: 从存档加载玩家数据
	player_data = PlayerData.new()
	game_progress = GameProgress.new()


func start_new_game() -> void:
	current_state = GameState.PLAYING
	game_progress.reset()
	SceneManager.change_scene("res://scenes/levels/level_01_street.tscn")


func continue_game() -> void:
	current_state = GameState.PLAYING
	# TODO: 加载存档并继续


func pause_game() -> void:
	current_state = GameState.PAUSED
	get_tree().paused = true


func resume_game() -> void:
	current_state = GameState.PLAYING
	get_tree().paused = false


func quit_to_main_menu() -> void:
	current_state = GameState.MAIN_MENU
	get_tree().paused = false
	SceneManager.change_scene("res://scenes/ui/main_menu.tscn")


func save_game() -> void:
	# TODO: 实现存档功能
	pass
