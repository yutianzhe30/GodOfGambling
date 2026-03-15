extends Node

## AudioManager - 音频管理器
## 管理背景音乐和音效的播放

@onready var bgm_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()

var bgm_volume: float = 1.0
var sfx_volume: float = 1.0


func _ready():
	add_child(bgm_player)
	add_child(sfx_player)
	bgm_player.bus = "Music"
	sfx_player.bus = "SFX"


func play_bgm(stream: AudioStream, loop: bool = true) -> void:
	if bgm_player.stream == stream and bgm_player.playing:
		return
	bgm_player.stream = stream
	bgm_player.stream.loop = loop
	bgm_player.volume_db = linear_to_db(bgm_volume)
	bgm_player.play()


func stop_bgm() -> void:
	bgm_player.stop()


func play_sfx(stream: AudioStream) -> void:
	# 使用独立的播放器避免重叠
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = stream
	player.volume_db = linear_to_db(sfx_volume)
	player.bus = "SFX"
	player.play()
	await player.finished
	player.queue_free()


func set_bgm_volume(volume: float) -> void:
	bgm_volume = clamp(volume, 0.0, 1.0)
	bgm_player.volume_db = linear_to_db(bgm_volume)


func set_sfx_volume(volume: float) -> void:
	sfx_volume = clamp(volume, 0.0, 1.0)
