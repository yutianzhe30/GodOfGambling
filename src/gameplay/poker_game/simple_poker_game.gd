extends Node
class_name SimplePokerGame

## SimplePokerGame - 简化版牌局控制器
## 用于测试和演示的简化版本

signal card_dealt(character: Character, card_data, hidden: bool)
signal winner_determined(winner: Character, amount: int)
signal player_turn_started

enum BettingAction {
	FOLD,
	CHECK,
	CALL,
	RAISE,
	ALL_IN
}

# 游戏状态
var deck = null
var pot: int = 0
var current_bet: int = 0

# 玩家
var player: Character = null
var opponent: Character = null
var all_players: Array = []

# 游戏进行中
var is_game_active: bool = false


func start_game(p: Character, o: Character) -> void:
	player = p
	opponent = o
	all_players = [player, opponent]
	
	# 初始化
	deck = Deck.new()
	deck.shuffle()
	pot = 0
	current_bet = 0
	is_game_active = true
	
	# 重置玩家状态
	for p_char in all_players:
		p_char.reset_round()
	
	# 发牌 - 每人1张底牌 + 5张明牌
	_deal_cards()
	
	# 模拟一些下注
	_simulate_betting()
	
	# 判定胜负
	_determine_winner()


func _deal_cards() -> void:
	for p_char in all_players:
		# 发1张底牌
		var hidden = deck.draw()
		if hidden:
			p_char.receive_card(hidden, true)
			card_dealt.emit(p_char, hidden, true)
		
		# 发5张明牌
		for i in range(5):
			var visible = deck.draw()
			if visible:
				p_char.receive_card(visible, false)
				card_dealt.emit(p_char, visible, false)


func _simulate_betting() -> void:
	# 简化版：每人下100底注
	for p_char in all_players:
		var bet = min(100, p_char.current_money)
		p_char.place_bet(bet)
		pot += bet


func _determine_winner() -> void:
	var player_result = player.get_hand_evaluation()
	var opponent_result = opponent.get_hand_evaluation()
	
	var winner: Character = null
	var compare = player_result.compare_to(opponent_result)
	
	if compare > 0:
		winner = player
	elif compare < 0:
		winner = opponent
	else:
		# 平局，随机选择
		winner = all_players[randi() % all_players.size()]
	
	if winner:
		winner.win_pot(pot)
		winner_determined.emit(winner, pot)


func player_action(action: BettingAction, amount: int = 0) -> void:
	# 简化版：玩家操作后直接结束
	match action:
		BettingAction.FOLD:
			player.fold()
			winner_determined.emit(opponent, pot)
		BettingAction.CALL:
			pass
		BettingAction.RAISE:
			pass
		BettingAction.ALL_IN:
			pass


func get_player_visible_cards() -> Array:
	if player:
		return player.get_visible_cards()
	return []


func get_opponent_visible_cards() -> Array:
	if opponent:
		return opponent.get_visible_cards()
	return []
