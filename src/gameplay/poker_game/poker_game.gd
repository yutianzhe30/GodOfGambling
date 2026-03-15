extends Node
class_name PokerGame

## PokerGame - 牌局主控制器
## 管理整个牌局流程

signal game_started
signal round_started(round_number: int)
signal turn_started(character: Character)
signal bet_made(character: Character, action: String, amount: int)
signal round_ended(winner: Character, pot: int)
signal game_ended(winner: Character)

enum GamePhase {
	SETUP,
	ANTE,
	DEAL_CARDS,
	BETTING_1,
	DRAW_PHASE,
	BETTING_2,
	SHOWDOWN,
	ROUND_END
}

# 游戏配置
var config: Dictionary = {
	"starting_money": 1000,
	"ante": 10,
	"min_bet": 10
}

# 游戏状态
var current_phase: GamePhase = GamePhase.SETUP
var current_round: int = 0
var pot: int = 0
var deck: Deck = Deck.new()
var community_cards: Array[Card] = []

# 参与者
var player: Player = null
var opponents: Array[NPC] = []
var all_characters: Array[Character] = []
var current_turn_index: int = 0

# 下注状态
var current_bet: int = 0  # 当前最高下注额
var bets_made: Dictionary = {}  # 每个角色的下注额


func _ready():
	pass


func setup_game(player_ref: Player, opponent_list: Array[NPC], game_config: Dictionary = {}) -> void:
	player = player_ref
	opponents = opponent_list
	all_characters = [player]
	all_characters.append_array(opponents)
	
	# 应用配置
	for key in game_config.keys():
		if config.has(key):
			config[key] = game_config[key]
	
	# 初始化玩家金钱
	player.current_money = config.starting_money
	for opponent in opponents:
		opponent.current_money = config.starting_money
	
	current_phase = GamePhase.SETUP


func start_game() -> void:
	game_started.emit()
	start_new_round()


func start_new_round() -> void:
	current_round += 1
	
	# 重置状态
	deck.reset()
	deck.shuffle()
	community_cards.clear()
	pot = 0
	current_bet = 0
	bets_made.clear()
	
	# 重置所有角色
	for character in all_characters:
		character.reset_for_round()
	
	round_started.emit(current_round)
	
	# 执行ante
	_execute_ante()
	
	# 发牌
	_deal_initial_cards()
	
	# 开始第一轮下注
	_start_betting_round()


func _execute_ante() -> void:
	current_phase = GamePhase.ANTE
	
	for character in all_characters:
		if character.current_money >= config.ante:
			var ante = character.place_bet(config.ante)
			pot += ante
			bets_made[character] = ante
		else:
			# 钱不够ante，全押
			var all_in = character.place_bet(character.current_money)
			pot += all_in
			bets_made[character] = all_in


func _deal_initial_cards() -> void:
	current_phase = GamePhase.DEAL_CARDS
	
	# 每人发5张牌
	for character in all_characters:
		var cards = deck.draw_n(5)
		for card in cards:
			character.add_card(card)


func _start_betting_round() -> void:
	current_phase = GamePhase.BETTING_1
	current_turn_index = 0
	_process_next_turn()


func _process_next_turn() -> void:
	# 找到下一个可以行动的角色
	var active_found = false
	var checked_count = 0
	
	while checked_count < all_characters.size():
		var character = all_characters[current_turn_index]
		
		if not character.has_folded and not character.is_all_in:
			active_found = true
			break
		
		current_turn_index = (current_turn_index + 1) % all_characters.size()
		checked_count += 1
	
	if not active_found:
		# 没有可以行动的角色，结束下注
		_end_betting_round()
		return
	
	var current_character = all_characters[current_turn_index]
	turn_started.emit(current_character)
	
	# 如果是NPC，自动决策
	if current_character is NPC:
		_make_npc_decision(current_character)


func _make_npc_decision(npc: NPC) -> void:
	var game_state = {
		"call_amount": current_bet,
		"pot": pot,
		"community_cards": community_cards
	}
	
	var decision = npc.make_decision(game_state)
	process_action(npc, decision.action, decision.amount)


func process_action(character: Character, action: String, amount: int = 0) -> bool:
	match action:
		"fold":
			character.fold()
			bet_made.emit(character, "fold", 0)
		
		"check":
			if not character.can_check(current_bet):
				return false
			bet_made.emit(character, "check", 0)
		
		"call":
			if not character.can_call(current_bet):
				return false
			var call_amount = current_bet - character.current_bet
			var actual_bet = character.place_bet(call_amount)
			pot += actual_bet
			bets_made[character] = character.current_bet
			bet_made.emit(character, "call", actual_bet)
		
		"raise":
			if not character.can_raise(amount):
				return false
			var actual_raise = character.place_bet(amount)
			pot += actual_raise
			current_bet = character.current_bet
			bets_made[character] = current_bet
			bet_made.emit(character, "raise", actual_raise)
		
		"all_in":
			var all_in_amount = character.place_bet(character.current_money)
			pot += all_in_amount
			if character.current_bet > current_bet:
				current_bet = character.current_bet
			bets_made[character] = character.current_bet
			bet_made.emit(character, "all_in", all_in_amount)
		
		_:
			return false
	
	# 检查是否只有一个玩家未弃牌
	var active_players = all_characters.filter(func(c): return not c.has_folded)
	if active_players.size() == 1:
		_end_round(active_players[0])
		return true
	
	# 移动到下一个玩家
	current_turn_index = (current_turn_index + 1) % all_characters.size()
	_process_next_turn()
	
	return true


func _end_betting_round() -> void:
	# TODO: 实现换牌阶段和第二轮下注
	# 简化为直接进入结算
	_resolve_showdown()


func _resolve_showdown() -> void:
	current_phase = GamePhase.SHOWDOWN
	
	var active_players = all_characters.filter(func(c): return not c.has_folded)
	
	if active_players.is_empty():
		_end_round(null)
		return
	
	# 评估每个玩家的牌
	var best_player = active_players[0]
	var best_hand = best_player.get_hand_evaluation()
	
	for i in range(1, active_players.size()):
		var player_result = active_players[i].get_hand_evaluation()
		if player_result.compare_to(best_hand) > 0:
			best_player = active_players[i]
			best_hand = player_result
	
	_end_round(best_player)


func _end_round(winner: Character) -> void:
	current_phase = GamePhase.ROUND_END
	
	if winner != null:
		winner.win_pot(pot)
		round_ended.emit(winner, pot)
	else:
		round_ended.emit(null, 0)
	
	# 检查游戏是否结束
	var bankrupt_count = 0
	for character in all_characters:
		if character.current_money <= 0:
			bankrupt_count += 1
	
	if player.current_money <= 0:
		game_ended.emit(opponents[0] if opponents.size() > 0 else null)
	elif opponents.all(func(o): return o.current_money <= 0):
		game_ended.emit(player)
