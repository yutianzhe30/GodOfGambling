extends Node2D

## 互动牌桌测试场景
## 展示真实可拖动的扑克牌 + 代码单元测试

const CARD_SIZE := Vector2(80, 112)
const HAND_SPREAD := 500

# Card framework
var card_manager_node: CardManager
var player_hand: Hand
var opponent_hand: Hand

# Game data
var data_deck: Deck
var game_player: GameCharacter
var game_opponent: GameCharacter
var xray_skill: SkillXRay
var xray_used := false

# UI refs (built programmatically)
var opp_lbl: Label
var player_lbl: Label
var info_lbl: Label
var log_lbl: Label
var xray_btn: Button


func _ready() -> void:
	_build_bg()
	_init_card_system()   # Must run before hands (sets scene meta)
	_init_hands()         # Must run after CardManager
	_build_ui()           # Added after hands so it renders on top
	_deal()


# ── scene setup ──────────────────────────────────────────────────────────────

func _build_bg() -> void:
	var bg := ColorRect.new()
	bg.size = Vector2(1280, 720)
	bg.color = Color(0.05, 0.22, 0.05)
	add_child(bg)


func _init_card_system() -> void:
	card_manager_node = CardManager.new()
	card_manager_node.card_size = CARD_SIZE
	card_manager_node.size = Vector2(1280, 720)
	# Do NOT set card_factory_scene — CardManager._ready() is deferred when called
	# from within _ready(), so we bypass it entirely and wire everything manually.
	add_child(card_manager_node)

	# Set scene meta immediately (CardContainer._find_and_register_card_manager uses this)
	get_tree().current_scene.set_meta("card_manager", card_manager_node)

	# Build factory directly — no dependency on CardManager._ready() timing
	var factory: JsonCardFactory = (load("res://addons/card-framework/card_factory.tscn") as PackedScene).instantiate()
	factory.card_info_dir  = "res://data/card_info"
	factory.card_asset_dir = "res://assets/images/cards"
	factory.back_image     = load("res://assets/images/cards/cardBack_blue2.png")
	factory.card_size      = CARD_SIZE
	card_manager_node.add_child(factory)
	card_manager_node.card_factory = factory
	factory.preload_card_data()


func _init_hands() -> void:
	var hs: PackedScene = load("res://addons/card-framework/hand.tscn")

	opponent_hand = hs.instantiate()
	opponent_hand.card_face_up    = false
	opponent_hand.max_hand_spread = HAND_SPREAD
	opponent_hand.position        = Vector2(640, 80)
	add_child(opponent_hand)   # _ready() finds CardManager via scene meta

	player_hand = hs.instantiate()
	player_hand.card_face_up    = true
	player_hand.max_hand_spread = HAND_SPREAD
	player_hand.position        = Vector2(640, 510)
	add_child(player_hand)


func _build_ui() -> void:
	# Top bar
	_rect(Vector2(0, 0),   Vector2(1280, 52), Color(0, 0, 0, 0.78))
	_label("赌神 · 互动牌桌", Vector2(20, 10), 24)

	# Opponent strip
	_rect(Vector2(0, 52),  Vector2(1280, 26), Color(0, 0, 0, 0.45))
	opp_lbl = _label("对手  |  底牌朝下", Vector2(20, 56), 14)

	# Player strip
	_rect(Vector2(0, 458), Vector2(1280, 26), Color(0, 0, 0, 0.45))
	player_lbl = _label("玩家  |  可拖动重排", Vector2(20, 462), 14)

	# Info panel (center, between the two hands)
	_rect(Vector2(420, 92), Vector2(440, 360), Color(0, 0, 0, 0.58))
	info_lbl = _label("", Vector2(430, 100), 14)
	info_lbl.size          = Vector2(420, 345)
	info_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	# Log panel (left side)
	_rect(Vector2(0, 92), Vector2(412, 360), Color(0, 0, 0, 0.58))
	_label("── 日志 ──", Vector2(10, 96), 13)
	log_lbl = _label("", Vector2(10, 116), 12)
	log_lbl.size          = Vector2(398, 330)
	log_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	# Bottom bar
	_rect(Vector2(0, 648), Vector2(1280, 72), Color(0, 0, 0, 0.78))
	_btn("重新发牌",          Vector2(20,  660), _deal)
	xray_btn = _btn("透视技能 (气场30)", Vector2(220, 660), _use_xray)
	_btn("单元测试",          Vector2(460, 660), _unit_test)
	var hint := _label("拖动手牌可重排  |  悬停放大查看", Vector2(700, 668), 13)
	hint.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75))


# ── game logic ───────────────────────────────────────────────────────────────

func _deal() -> void:
	xray_used = false
	if xray_btn:
		xray_btn.disabled = false

	player_hand.clear_cards()
	opponent_hand.clear_cards()

	if not game_player:
		game_player = GameCharacter.new()
		game_player.character_name = "玩家"
		add_child(game_player)
	else:
		game_player.reset_round()
	game_player.current_money = 1000
	game_player.set_aura(100)

	if not game_opponent:
		game_opponent = GameCharacter.new()
		game_opponent.character_name = "对手"
		add_child(game_opponent)
	else:
		game_opponent.reset_round()
	game_opponent.current_money = 1000

	data_deck = Deck.new()
	data_deck.shuffle()

	# Player: 1 hidden + 5 visible
	var p_hidden: CardData = data_deck.draw()
	game_player.receive_card(p_hidden, true)
	_spawn(p_hidden.card_name, player_hand)
	for _i in 5:
		var c: CardData = data_deck.draw()
		game_player.receive_card(c, false)
		_spawn(c.card_name, player_hand)

	# Opponent: 1 hidden + 5 visible (all face-down visually)
	for i in 6:
		var c: CardData = data_deck.draw()
		game_opponent.receive_card(c, i == 0)
		_spawn(c.card_name, opponent_hand)

	xray_skill = SkillXRay.new()
	_refresh()
	_log("新局开始 — 双方各发6张牌 (1底牌+5明牌)")
	var hidden = game_player.get_hidden_card()
	if hidden:
		_log("你的底牌: %s  (仅自己可见)" % hidden.get_display_name())


func _use_xray() -> void:
	if xray_used:
		return
	var ok := xray_skill.use(game_player, game_opponent)
	if ok and xray_skill.is_active():
		var revealed: CardData = xray_skill.get_revealed_card()
		xray_used = true
		xray_btn.disabled = true
		_log("透视成功! 对手底牌: %s" % revealed.get_display_name())
		_log("剩余气场: %d" % game_player.get_aura())
	else:
		_log("透视失败 (气场不足: %d / 需要30)" % game_player.get_aura())
	_refresh()


func _refresh() -> void:
	if not game_player or not game_opponent:
		return

	var p_vis: Array = game_player.get_visible_cards()
	var o_vis: Array = game_opponent.get_visible_cards()

	var p_rank := "—"
	var o_rank := "—"
	if p_vis.size() == 5:
		p_rank = HandEvaluator.evaluate(p_vis).get_rank_name()
	if o_vis.size() == 5:
		o_rank = HandEvaluator.evaluate(o_vis).get_rank_name()

	var hidden_str := "???"
	if xray_used and xray_skill and xray_skill.is_active():
		hidden_str = xray_skill.get_revealed_card().get_display_name()

	var p_hidden = game_player.get_hidden_card()
	player_lbl.text = "玩家  底牌: %s  |  明牌型: %s  |  气场: %d/%d  |  金: %d" % [
		p_hidden.get_display_name() if p_hidden else "?",
		p_rank,
		game_player.get_aura(), game_player.max_aura,
		game_player.current_money
	]
	opp_lbl.text = "对手  底牌: %s  |  明牌型: %s  |  金: %d" % [
		hidden_str, o_rank, game_opponent.current_money
	]

	var xray_state := "可用 (消耗30气场)" if not xray_used else "已使用"
	info_lbl.text = (
		"牌局状态\n\n"
		+ "  玩家底牌:    %s\n" % (p_hidden.get_display_name() if p_hidden else "?")
		+ "  玩家明牌型:  %s\n\n" % p_rank
		+ "  对手底牌:    %s\n" % hidden_str
		+ "  对手明牌型:  %s\n\n" % o_rank
		+ "  玩家气场:    %d / %d\n" % [game_player.get_aura(), game_player.max_aura]
		+ "  透视技能:    %s\n\n" % xray_state
		+ "  提示: 拖动手牌可重新排列\n"
		+ "  右侧朝下是对手牌 (底牌未知)\n"
		+ "  点透视技能查看对手底牌"
	)


# ── unit tests ───────────────────────────────────────────────────────────────

func _unit_test() -> void:
	_log("── 单元测试开始 ──")

	# CardData
	var c := CardData.new(CardData.Suit.HEARTS, CardData.Rank.ACE)
	assert(c.get_display_name() == "红桃A", "CardData display name")
	assert(c.card_name == "heart_A",        "CardData card_name")
	_log("  CardData       通过")

	# Deck
	var d := Deck.new()
	assert(d.remaining() == 52, "Deck size")
	d.shuffle()
	assert(d.draw() != null,    "Deck draw")
	assert(d.remaining() == 51, "Deck remaining")
	_log("  Deck           通过")

	# HandEvaluator — straight flush
	var sf := [
		CardData.new(CardData.Suit.HEARTS, CardData.Rank.TEN),
		CardData.new(CardData.Suit.HEARTS, CardData.Rank.JACK),
		CardData.new(CardData.Suit.HEARTS, CardData.Rank.QUEEN),
		CardData.new(CardData.Suit.HEARTS, CardData.Rank.KING),
		CardData.new(CardData.Suit.HEARTS, CardData.Rank.ACE),
	]
	assert(HandEvaluator.evaluate(sf).hand_rank == HandEvaluator.HandRank.STRAIGHT_FLUSH, "HandEvaluator SF")
	_log("  HandEvaluator  通过 (同花顺)")

	# SkillXRay
	var src := GameCharacter.new()
	var tgt := GameCharacter.new()
	add_child(src)
	add_child(tgt)
	src.set_aura(100)
	tgt.receive_card(CardData.new(CardData.Suit.SPADES, CardData.Rank.ACE), true)
	var xr := SkillXRay.new()
	assert(xr.use(src, tgt) == true,                          "XRay use")
	assert(xr.get_revealed_card().suit == CardData.Suit.SPADES, "XRay reveal suit")
	_log("  SkillXRay      通过")
	src.queue_free()
	tgt.queue_free()

	_log("── 全部通过 ✓ ──")


# ── helpers ──────────────────────────────────────────────────────────────────

func _spawn(card_name: String, container: Hand) -> Card:
	return card_manager_node.card_factory.create_card(card_name, container)


func _log(msg: String) -> void:
	var cur := log_lbl.text.strip_edges()
	var lines: Array = [] if cur.is_empty() else Array(cur.split("\n"))
	lines.append(msg)
	if lines.size() > 9:
		lines = lines.slice(lines.size() - 9)
	var result := ""
	for i in lines.size():
		if i > 0:
			result += "\n"
		result += str(lines[i])
	log_lbl.text = result
	print(msg)


func _rect(pos: Vector2, size: Vector2, color: Color) -> ColorRect:
	var r := ColorRect.new()
	r.position = pos
	r.size     = size
	r.color    = color
	add_child(r)
	return r


func _label(text: String, pos: Vector2, font_size: int) -> Label:
	var l := Label.new()
	l.text     = text
	l.position = pos
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", Color.WHITE)
	add_child(l)
	return l


func _btn(text: String, pos: Vector2, cb: Callable) -> Button:
	var b := Button.new()
	b.text     = text
	b.position = pos
	b.size     = Vector2(190, 40)
	b.add_theme_font_size_override("font_size", 15)
	b.pressed.connect(cb)
	add_child(b)
	return b
