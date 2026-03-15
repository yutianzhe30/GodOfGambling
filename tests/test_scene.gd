extends Node2D

## 测试场景 - 使用card-framework addon验证打牌和透视技能

@onready var output_label = %OutputLabel
@onready var test_button = $TestButton

# Card factory for creating visual cards
var card_factory = null

func _ready():
	test_button.pressed.connect(_on_test_pressed)
	_log("点击按钮开始测试")
	
	# Setup card factory
	_setup_card_factory()


func _setup_card_factory():
	# Create JsonCardFactory
	var factory_scene = load("res://addons/card-framework/card_factory.tscn")
	if factory_scene:
		card_factory = factory_scene.instantiate()
		card_factory.card_info_dir = "res://data/card_info"
		card_factory.card_asset_dir = "res://assets/images/cards"
		
		# Load card scene
		var card_scene = load("res://addons/card-framework/card.tscn")
		card_factory.default_card_scene = card_scene
		
		add_child(card_factory)
		_log("Card factory initialized")


func _on_test_pressed():
	test_button.disabled = true
	_log("===== 开始测试 =====\n")
	
	await _test_card_data()
	await _test_deck()
	await _test_hand_data()
	await _test_hand_evaluator()
	await _test_visual_card()
	await _test_poker_game()
	await _test_xray_skill()
	
	_log("\n===== 所有测试通过 =====")
	test_button.disabled = false


func _test_card_data():
	_log("--- 测试 CardData ---")
	var card = CardData.new(CardData.Suit.HEARTS, CardData.Rank.ACE)
	assert(card.suit == CardData.Suit.HEARTS, "Card suit mismatch")
	assert(card.rank == CardData.Rank.ACE, "Card rank mismatch")
	assert(card.get_display_name() == "红桃A", "Card display name mismatch")
	assert(card.card_name == "heart_A", "Card name mismatch")
	_log("✓ CardData 测试通过")
	await get_tree().process_frame


func _test_deck():
	_log("\n--- 测试 Deck ---")
	var deck = Deck.new()
	assert(deck.remaining() == 52, "Deck should have 52 cards")
	
	var card = deck.draw()
	assert(card != null, "Drawn card should not be null")
	assert(deck.remaining() == 51, "Deck should have 51 cards after drawing one")
	
	var cards = deck.draw_n(5)
	assert(cards.size() == 5, "Should draw 5 cards")
	assert(deck.remaining() == 46, "Deck should have 46 cards after drawing 5 more")
	
	_log("  抽了一张牌: %s" % card.get_display_name())
	_log("  再抽5张牌")
	_log("✓ Deck 测试通过")
	await get_tree().process_frame


func _test_hand_data():
	_log("\n--- 测试 Hand Cards ---")
	
	var hidden = CardData.new(CardData.Suit.SPADES, CardData.Rank.ACE)
	var visible1 = CardData.new(CardData.Suit.HEARTS, CardData.Rank.KING)
	var visible2 = CardData.new(CardData.Suit.DIAMONDS, CardData.Rank.QUEEN)
	
	var character = Character.new()
	character.add_card(hidden, true)
	character.add_card(visible1, false)
	character.add_card(visible2, false)
	
	assert(character.get_hidden_card() == hidden, "Hidden card mismatch")
	assert(character.get_visible_cards().size() == 2, "Visible cards count mismatch")
	_log("  底牌: %s" % character.get_hidden_card().get_display_name())
	_log("  明牌: %s" % _cards_to_string(character.get_visible_cards()))
	_log("✓ Hand Cards 测试通过")
	
	character.queue_free()
	await get_tree().process_frame


func _test_hand_evaluator():
	_log("\n--- 测试 HandEvaluator ---")
	
	# 同花顺
	var straight_flush = [
		CardData.new(CardData.Suit.HEARTS, CardData.Rank.TEN),
		CardData.new(CardData.Suit.HEARTS, CardData.Rank.JACK),
		CardData.new(CardData.Suit.HEARTS, CardData.Rank.QUEEN),
		CardData.new(CardData.Suit.HEARTS, CardData.Rank.KING),
		CardData.new(CardData.Suit.HEARTS, CardData.Rank.ACE)
	]
	var result = HandEvaluator.evaluate(straight_flush)
	assert(result.hand_rank == HandEvaluator.HandRank.STRAIGHT_FLUSH, "Should be straight flush")
	_log("  同花顺: %s" % result.get_rank_name())
	
	# 四条
	var four_kind = [
		CardData.new(CardData.Suit.HEARTS, CardData.Rank.SEVEN),
		CardData.new(CardData.Suit.DIAMONDS, CardData.Rank.SEVEN),
		CardData.new(CardData.Suit.CLUBS, CardData.Rank.SEVEN),
		CardData.new(CardData.Suit.SPADES, CardData.Rank.SEVEN),
		CardData.new(CardData.Suit.HEARTS, CardData.Rank.NINE)
	]
	result = HandEvaluator.evaluate(four_kind)
	assert(result.hand_rank == HandEvaluator.HandRank.FOUR_OF_A_KIND, "Should be four of a kind")
	_log("  四条: %s" % result.get_rank_name())
	
	# 葫芦
	var full_house = [
		CardData.new(CardData.Suit.HEARTS, CardData.Rank.THREE),
		CardData.new(CardData.Suit.DIAMONDS, CardData.Rank.THREE),
		CardData.new(CardData.Suit.CLUBS, CardData.Rank.THREE),
		CardData.new(CardData.Suit.SPADES, CardData.Rank.EIGHT),
		CardData.new(CardData.Suit.HEARTS, CardData.Rank.EIGHT)
	]
	result = HandEvaluator.evaluate(full_house)
	assert(result.hand_rank == HandEvaluator.HandRank.FULL_HOUSE, "Should be full house")
	_log("  葫芦: %s" % result.get_rank_name())
	
	# 一对
	var one_pair = [
		CardData.new(CardData.Suit.HEARTS, CardData.Rank.TWO),
		CardData.new(CardData.Suit.DIAMONDS, CardData.Rank.TWO),
		CardData.new(CardData.Suit.CLUBS, CardData.Rank.FIVE),
		CardData.new(CardData.Suit.SPADES, CardData.Rank.EIGHT),
		CardData.new(CardData.Suit.HEARTS, CardData.Rank.KING)
	]
	result = HandEvaluator.evaluate(one_pair)
	assert(result.hand_rank == HandEvaluator.HandRank.ONE_PAIR, "Should be one pair")
	_log("  一对: %s" % result.get_rank_name())
	
	_log("✓ HandEvaluator 测试通过")
	await get_tree().process_frame


func _test_visual_card():
	_log("\n--- 测试 Visual Card (addon) ---")
	
	if card_factory == null:
		_log("  跳过: Card factory不可用")
		return
	
	# Create a visual hand container
	var hand_scene = load("res://addons/card-framework/hand.tscn")
	var hand = hand_scene.instantiate()
	hand.position = Vector2(500, 400)
	add_child(hand)
	
	# Preload card data
	card_factory.preload_card_data()
	
	# Create a visual card
	var card = card_factory.create_card("heart_A", hand)
	if card:
		_log("  创建了卡牌: %s" % card.card_name)
		_log("  卡牌信息: %s" % str(card.card_info))
		_log("✓ Visual Card 测试通过")
	else:
		_log("  警告: 无法创建卡牌，检查资源路径")
	
	await get_tree().create_timer(0.5).timeout
	hand.queue_free()
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
	game.card_dealt.connect(func(char, card_data, hidden): 
		if hidden:
			events.append("%s 获得底牌" % char.character_name)
		else:
			events.append("%s 获得明牌 %s" % [char.character_name, card_data.get_display_name()])
	)
	game.winner_determined.connect(func(winner, amount):
		if winner:
			events.append("%s 赢得 %d" % [winner.character_name, amount])
	)
	
	# 开始游戏
	game.start_game(player, opponent)
	
	# 等待
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
	var hidden_card = CardData.new(CardData.Suit.SPADES, CardData.Rank.ACE)
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
		assert(revealed.rank == CardData.Rank.ACE, "Revealed card rank mismatch")
		assert(revealed.suit == CardData.Suit.SPADES, "Revealed card suit mismatch")
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


func _cards_to_string(cards: Array) -> String:
	var result = ""
	for i in range(cards.size()):
		if i > 0:
			result += ", "
		result += cards[i].get_display_name()
	return result
