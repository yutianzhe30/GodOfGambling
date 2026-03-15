extends Node

## test_poker_core.gd - 扑克核心系统单元测试

func _ready():
	print("===== 运行扑克核心单元测试 =====\n")
	
	test_card_data_creation()
	test_deck_operations()
	test_hand_management()
	test_hand_evaluation()
	
	print("\n===== 单元测试完成 =====")


func test_card_data_creation():
	print("--- 测试 CardData 创建 ---")
	
	# 测试不同花色和点数
	var heart_ace = CardData.new(CardData.Suit.HEARTS, CardData.Rank.ACE)
	assert(heart_ace.suit == CardData.Suit.HEARTS)
	assert(heart_ace.rank == CardData.Rank.ACE)
	assert(heart_ace.get_display_name() == "红桃A")
	assert(heart_ace.card_name == "heart_A")
	
	var spade_king = CardData.new(CardData.Suit.SPADES, CardData.Rank.KING)
	assert(spade_king.get_display_name() == "黑桃K")
	assert(spade_king.card_name == "spade_K")
	
	var diamond_10 = CardData.new(CardData.Suit.DIAMONDS, CardData.Rank.TEN)
	assert(diamond_10.get_display_name() == "方块10")
	assert(diamond_10.card_name == "diamond_10")
	
	var club_2 = CardData.new(CardData.Suit.CLUBS, CardData.Rank.TWO)
	assert(club_2.get_display_name() == "梅花2")
	assert(club_2.card_name == "club_2")
	
	# 测试从名称创建
	var from_name = CardData.from_name("heart_Q")
	assert(from_name != null)
	assert(from_name.suit == CardData.Suit.HEARTS)
	assert(from_name.rank == CardData.Rank.QUEEN)
	
	print("✓ CardData 创建测试通过")


func test_deck_operations():
	print("\n--- 测试 Deck 操作 ---")
	
	var deck = Deck.new()
	
	# 初始状态
	assert(deck.remaining() == 52, "新牌组应该有52张牌")
	
	# 洗牌
	deck.shuffle()
	assert(deck.remaining() == 52, "洗牌后牌数不变")
	
	# 抽单张
	var card = deck.draw()
	assert(card != null, "应该能抽到牌")
	assert(deck.remaining() == 51, "抽一张后剩51张")
	
	# 抽多张
	var cards = deck.draw_n(5)
	assert(cards.size() == 5, "应该抽到5张牌")
	assert(deck.remaining() == 46, "抽5张后剩46张")
	
	# 抽完
	var remaining = deck.remaining()
	for i in range(remaining):
		deck.draw()
	assert(deck.is_empty(), "全部抽完后应该为空")
	assert(deck.draw() == null, "空牌组抽牌返回null")
	
	# 重置
	deck.reset()
	assert(deck.remaining() == 52, "重置后恢复52张")
	
	print("✓ Deck 操作测试通过")


func test_hand_management():
	print("\n--- 测试 Hand 管理 ---")
	
	var character = Character.new()
	assert(character.get_hand_cards().size() == 0, "初始手牌为空")
	
	# 添加明牌
	var card1 = CardData.new(CardData.Suit.HEARTS, CardData.Rank.ACE)
	character.add_card(card1, false)
	assert(character.get_hand_cards().size() == 1)
	assert(character.get_visible_cards().size() == 1)
	
	# 添加底牌
	var card2 = CardData.new(CardData.Suit.SPADES, CardData.Rank.KING)
	character.add_card(card2, true)
	assert(character.get_hand_cards().size() == 2)
	assert(character.get_hidden_card() == card2)
	assert(character.get_visible_cards().size() == 1)
	
	# 清空
	character.reset_round()
	assert(character.get_hand_cards().size() == 0)
	
	character.queue_free()
	print("✓ Hand 管理测试通过")


func test_hand_evaluation():
	print("\n--- 测试 HandEvaluator 牌型判定 ---")
	
	# 同花顺
	var straight_flush = _create_hand([
		[CardData.Suit.HEARTS, CardData.Rank.TEN],
		[CardData.Suit.HEARTS, CardData.Rank.JACK],
		[CardData.Suit.HEARTS, CardData.Rank.QUEEN],
		[CardData.Suit.HEARTS, CardData.Rank.KING],
		[CardData.Suit.HEARTS, CardData.Rank.ACE]
	])
	var result = HandEvaluator.evaluate(straight_flush)
	assert(result.hand_rank == HandEvaluator.HandRank.STRAIGHT_FLUSH, "应该是同花顺")
	print("  同花顺: %s" % result.get_rank_name())
	
	# 四条
	var four_kind = _create_hand([
		[CardData.Suit.HEARTS, CardData.Rank.SEVEN],
		[CardData.Suit.DIAMONDS, CardData.Rank.SEVEN],
		[CardData.Suit.CLUBS, CardData.Rank.SEVEN],
		[CardData.Suit.SPADES, CardData.Rank.SEVEN],
		[CardData.Suit.HEARTS, CardData.Rank.NINE]
	])
	result = HandEvaluator.evaluate(four_kind)
	assert(result.hand_rank == HandEvaluator.HandRank.FOUR_OF_A_KIND, "应该是四条")
	print("  四条: %s" % result.get_rank_name())
	
	# 葫芦
	var full_house = _create_hand([
		[CardData.Suit.HEARTS, CardData.Rank.THREE],
		[CardData.Suit.DIAMONDS, CardData.Rank.THREE],
		[CardData.Suit.CLUBS, CardData.Rank.THREE],
		[CardData.Suit.SPADES, CardData.Rank.EIGHT],
		[CardData.Suit.HEARTS, CardData.Rank.EIGHT]
	])
	result = HandEvaluator.evaluate(full_house)
	assert(result.hand_rank == HandEvaluator.HandRank.FULL_HOUSE, "应该是葫芦")
	print("  葫芦: %s" % result.get_rank_name())
	
	# 同花
	var flush = _create_hand([
		[CardData.Suit.CLUBS, CardData.Rank.TWO],
		[CardData.Suit.CLUBS, CardData.Rank.FIVE],
		[CardData.Suit.CLUBS, CardData.Rank.EIGHT],
		[CardData.Suit.CLUBS, CardData.Rank.JACK],
		[CardData.Suit.CLUBS, CardData.Rank.ACE]
	])
	result = HandEvaluator.evaluate(flush)
	assert(result.hand_rank == HandEvaluator.HandRank.FLUSH, "应该是同花")
	print("  同花: %s" % result.get_rank_name())
	
	# 顺子
	var straight = _create_hand([
		[CardData.Suit.HEARTS, CardData.Rank.FIVE],
		[CardData.Suit.DIAMONDS, CardData.Rank.SIX],
		[CardData.Suit.CLUBS, CardData.Rank.SEVEN],
		[CardData.Suit.SPADES, CardData.Rank.EIGHT],
		[CardData.Suit.HEARTS, CardData.Rank.NINE]
	])
	result = HandEvaluator.evaluate(straight)
	assert(result.hand_rank == HandEvaluator.HandRank.STRAIGHT, "应该是顺子")
	print("  顺子: %s" % result.get_rank_name())
	
	# 三条
	var three_kind = _create_hand([
		[CardData.Suit.HEARTS, CardData.Rank.FOUR],
		[CardData.Suit.DIAMONDS, CardData.Rank.FOUR],
		[CardData.Suit.CLUBS, CardData.Rank.FOUR],
		[CardData.Suit.SPADES, CardData.Rank.NINE],
		[CardData.Suit.HEARTS, CardData.Rank.KING]
	])
	result = HandEvaluator.evaluate(three_kind)
	assert(result.hand_rank == HandEvaluator.HandRank.THREE_OF_A_KIND, "应该是三条")
	print("  三条: %s" % result.get_rank_name())
	
	# 两对
	var two_pairs = _create_hand([
		[CardData.Suit.HEARTS, CardData.Rank.TWO],
		[CardData.Suit.DIAMONDS, CardData.Rank.TWO],
		[CardData.Suit.CLUBS, CardData.Rank.SEVEN],
		[CardData.Suit.SPADES, CardData.Rank.SEVEN],
		[CardData.Suit.HEARTS, CardData.Rank.ACE]
	])
	result = HandEvaluator.evaluate(two_pairs)
	assert(result.hand_rank == HandEvaluator.HandRank.TWO_PAIRS, "应该是两对")
	print("  两对: %s" % result.get_rank_name())
	
	# 一对
	var one_pair = _create_hand([
		[CardData.Suit.HEARTS, CardData.Rank.THREE],
		[CardData.Suit.DIAMONDS, CardData.Rank.THREE],
		[CardData.Suit.CLUBS, CardData.Rank.SEVEN],
		[CardData.Suit.SPADES, CardData.Rank.TEN],
		[CardData.Suit.HEARTS, CardData.Rank.KING]
	])
	result = HandEvaluator.evaluate(one_pair)
	assert(result.hand_rank == HandEvaluator.HandRank.ONE_PAIR, "应该是一对")
	print("  一对: %s" % result.get_rank_name())
	
	# 高牌
	var high_card = _create_hand([
		[CardData.Suit.HEARTS, CardData.Rank.TWO],
		[CardData.Suit.DIAMONDS, CardData.Rank.FIVE],
		[CardData.Suit.CLUBS, CardData.Rank.EIGHT],
		[CardData.Suit.SPADES, CardData.Rank.JACK],
		[CardData.Suit.HEARTS, CardData.Rank.ACE]
	])
	result = HandEvaluator.evaluate(high_card)
	assert(result.hand_rank == HandEvaluator.HandRank.HIGH_CARD, "应该是高牌")
	print("  高牌: %s" % result.get_rank_name())
	
	# 牌型比较
	var cmp = HandEvaluator.compare_hands(straight_flush, four_kind)
	assert(cmp > 0, "同花顺应该大于四条")
	
	cmp = HandEvaluator.compare_hands(one_pair, two_pairs)
	assert(cmp < 0, "一对应该小于两对")
	
	print("✓ HandEvaluator 测试通过")


# 辅助函数：从数组创建手牌
func _create_hand(card_data: Array) -> Array:
	var result = []
	for data in card_data:
		result.append(CardData.new(data[0], data[1]))
	return result
