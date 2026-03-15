extends Node2D

## 测试场景 - 验证打牌和透视技能

@onready var output_label = %OutputLabel
@onready var test_button = $TestButton

func _ready():
	test_button.pressed.connect(_on_test_pressed)
	_log("点击按钮开始测试")

func _on_test_pressed():
	test_button.disabled = true
	_log("===== 开始测试 =====\n")
	
	await _test_card()
	await _test_deck()
	await _test_hand()
	await _test_hand_evaluator()
	await _test_poker_game()
	await _test_xray_skill()
	
	_log("\n===== 所有测试通过 =====")
	test_button.disabled = false

func _test_card():
	_log("--- 测试 Card ---")
	var card = Card.new(Card.Suit.HEARTS, Card.Rank.ACE)
	assert(card.suit == Card.Suit.HEARTS, "Card suit mismatch")
	assert(card.rank == Card.Rank.ACE, "Card rank mismatch")
	assert(card.get_display_name() == "红桃A", "Card display name mismatch")
	_log("✓ Card 测试通过")
	await get_tree().process_frame

func _test_deck():
	_log("\n--- 测试 Deck ---")
	var deck = Deck.new()
	assert(deck.remaining() == 52, "Deck should have 52 cards")
	
	var card = deck.draw_card()
	assert(card != null, "Drawn card should not be null")
	assert(deck.remaining() == 51, "Deck should have 51 cards after drawing one")
	
	var cards = deck.draw_cards(5)
	assert(cards.size() == 5, "Should draw 5 cards")
	assert(deck.remaining() == 46, "Deck should have 46 cards after drawing 5 more")
	
	_log("  抽了一张牌: %s" % card.get_display_name())
	_log("  再抽5张牌")
	_log("✓ Deck 测试通过")
	await get_tree().process_frame

func _test_hand():
	_log("\n--- 测试 Hand ---")
	var hand = Hand.new()
	
	var hidden = Card.new(Card.Suit.SPADES, Card.Rank.ACE)
	var visible1 = Card.new(Card.Suit.HEARTS, Card.Rank.KING)
	var visible2 = Card.new(Card.Suit.DIAMONDS, Card.Rank.QUEEN)
	
	hand.add_card(hidden, true)
	hand.add_card(visible1, false)
	hand.add_card(visible2, false)
	
	assert(hand.get_hidden_card() == hidden, "Hidden card mismatch")
	assert(hand.get_visible_cards().size() == 2, "Visible cards count mismatch")
	_log("  底牌: %s" % hand.get_hidden_card().get_display_name())
	_log("  明牌: %s" % _cards_to_string(hand.get_visible_cards()))
	_log("✓ Hand 测试通过")
	await get_tree().process_frame

func _test_hand_evaluator():
	_log("\n--- 测试 HandEvaluator ---")
	
	# 同花顺
	var straight_flush = [
		Card.new(Card.Suit.HEARTS, Card.Rank.TEN),
		Card.new(Card.Suit.HEARTS, Card.Rank.JACK),
		Card.new(Card.Suit.HEARTS, Card.Rank.QUEEN),
		Card.new(Card.Suit.HEARTS, Card.Rank.KING),
		Card.new(Card.Suit.HEARTS, Card.Rank.ACE)
	]
	var result = HandEvaluator.evaluate(straight_flush)
	assert(result.hand_rank == HandEvaluator.HandRank.STRAIGHT_FLUSH, "Should be straight flush")
	_log("  同花顺: %s" % result.get_rank_name())
	
	# 四条
	var four_kind = [
		Card.new(Card.Suit.HEARTS, Card.Rank.SEVEN),
		Card.new(Card.Suit.DIAMONDS, Card.Rank.SEVEN),
		Card.new(Card.Suit.CLUBS, Card.Rank.SEVEN),
		Card.new(Card.Suit.SPADES, Card.Rank.SEVEN),
		Card.new(Card.Suit.HEARTS, Card.Rank.NINE)
	]
	result = HandEvaluator.evaluate(four_kind)
	assert(result.hand_rank == HandEvaluator.HandRank.FOUR_OF_A_KIND, "Should be four of a kind")
	_log("  四条: %s" % result.get_rank_name())
	
	# 葫芦
	var full_house = [
		Card.new(Card.Suit.HEARTS, Card.Rank.THREE),
		Card.new(Card.Suit.DIAMONDS, Card.Rank.THREE),
		Card.new(Card.Suit.CLUBS, Card.Rank.THREE),
		Card.new(Card.Suit.SPADES, Card.Rank.EIGHT),
		Card.new(Card.Suit.HEARTS, Card.Rank.EIGHT)
	]
	result = HandEvaluator.evaluate(full_house)
	assert(result.hand_rank == HandEvaluator.HandRank.FULL_HOUSE, "Should be full house")
	_log("  葫芦: %s" % result.get_rank_name())
	
	# 一对
	var one_pair = [
		Card.new(Card.Suit.HEARTS, Card.Rank.TWO),
		Card.new(Card.Suit.DIAMONDS, Card.Rank.TWO),
		Card.new(Card.Suit.CLUBS, Card.Rank.FIVE),
		Card.new(Card.Suit.SPADES, Card.Rank.EIGHT),
		Card.new(Card.Suit.HEARTS, Card.Rank.KING)
	]
	result = HandEvaluator.evaluate(one_pair)
	assert(result.hand_rank == HandEvaluator.HandRank.ONE_PAIR, "Should be one pair")
	_log("  一对: %s" % result.get_rank_name())
	
	_log("✓ HandEvaluator 测试通过")
	await get_tree().process_frame

func _test_poker_game():
	_log("\n--- 测试 PokerGame ---")
	
	# 创建角色
	var player = GameCharacter.new()
	player.character_name = "玩家"
	player.current_money = 1000
	add_child(player)
	
	var opponent = GameCharacter.new()
	opponent.character_name = "AI对手"
	opponent.current_money = 1000
	add_child(opponent)
	
	# 创建牌局
	var game = SimplePokerGame.new()
	add_child(game)
	
	# 记录事件
	var events: Array[String] = []
	game.card_dealt.connect(func(char, card, hidden): 
		if hidden:
			events.append("%s 获得底牌" % char.character_name)
		else:
			events.append("%s 获得明牌 %s" % [char.character_name, card.get_display_name()])
	)
	game.winner_determined.connect(func(winner, amount):
		if winner:
			events.append("%s 赢得 %d" % [winner.character_name, amount])
	)
	
	# 开始游戏
	game.start_game(player, opponent)
	
	# 等待AI完成
	await get_tree().create_timer(0.5).timeout
	
	_log("  游戏流程:")
	for event in events:
		_log("    - %s" % event)
	
	_log("✓ PokerGame 测试通过")
	
	# 清理
	player.queue_free()
	opponent.queue_free()
	game.queue_free()
	await get_tree().process_frame

func _test_xray_skill():
	_log("\n--- 测试 透视技能 ---")
	
	# 创建角色
	var player = GameCharacter.new()
	player.character_name = "玩家"
	add_child(player)
	
	var opponent = GameCharacter.new()
	opponent.character_name = "对手"
	add_child(opponent)
	
	# 给对手发底牌
	opponent.reset_round()
	var hidden_card = Card.new(Card.Suit.SPADES, Card.Rank.ACE)
	opponent.receive_card(hidden_card, true)
	
	_log("  对手底牌(真实): %s" % hidden_card.get_display_name())
	
	# 设置玩家气场
	player.set_aura(100)
	_log("  玩家气场: %d" % player.get_aura())
	
	# 使用透视技能
	var xray = SkillXRay.new()
	var success = xray.use(player, opponent)
	
	if success and xray.is_active():
		var revealed = xray.get_revealed_card()
		_log("  透视成功! 看到底牌: %s" % revealed.get_display_name())
		_log("  剩余气场: %d" % player.get_aura())
		assert(revealed.rank == Card.Rank.ACE, "Revealed card rank mismatch")
		assert(revealed.suit == Card.Suit.SPADES, "Revealed card suit mismatch")
		_log("✓ 透视技能测试通过")
	else:
		_log("✗ 透视技能测试失败")
	
	# 清理
	player.queue_free()
	opponent.queue_free()
	await get_tree().process_frame

func _log(text: String):
	output_label.text += text + "\n"
	print(text)

func _cards_to_string(cards: Array[Card]) -> String:
	var result = ""
	for i in range(cards.size()):
		if i > 0:
			result += ", "
		result += cards[i].get_display_name()
	return result
