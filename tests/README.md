# 测试说明

## 文件结构

```
tests/
├── TestScene.tscn      # Godot测试场景
├── test_scene.gd       # 测试脚本
├── unit/               # 单元测试
│   └── test_poker_core.gd
└── README.md           # 本文件
```
## 资源
使用addons/cardframework
还有card_info中的cards
card image 在assets/images/card中

## 基本功能
发牌  包括发如手牌（对手看不见）以及明牌（双方互相看见）
发一套（1张手牌5张明牌）
判定

## 如何运行测试

### 方法1: 直接在Godot中运行

1. 打开 Godot 4.2+
2. 导入本项目
3. 直接按 F5 或点击"运行项目"
4. 点击"运行测试"按钮

### 方法2: 查看测试代码

打开 `test_scene.gd` 查看完整的测试代码，了解API用法。

## 测试覆盖内容

### 1. Card 测试
- 创建扑克牌
- 显示名称
- 资源名称

### 2. Deck 测试
- 创建52张牌
- 洗牌
- 发牌
- 重置

### 3. Hand 测试
- 添加明牌/底牌
- 获取底牌
- 获取所有牌

### 4. HandEvaluator 测试
- 识别所有牌型（同花顺、四条、葫芦等）
- 牌型大小比较

### 5. PokerGame 测试
- 创建牌局
- 发牌流程
- AI决策
- 结算

### 6. SkillXRay 测试
- 使用透视技能
- 查看对手底牌
- 气场消耗

## 核心API速查

### Card (扑克牌)
```gdscript
var card = Card.new(Card.Suit.HEARTS, Card.Rank.ACE)
print(card.get_display_name())  # "红桃A"
```

### Deck (牌组)
```gdscript
var deck = Deck.new()
deck.shuffle()
var card = deck.draw_card()
var cards = deck.draw_cards(5)
```

### Hand (手牌)
```gdscript
var hand = Hand.new()
hand.add_card(card, true)   # true = 底牌
hand.add_card(card2, false) # false = 明牌
var hidden = hand.get_hidden_card()
var visible = hand.get_visible_cards()
```

### HandEvaluator (牌型判定)
```gdscript
var result = HandEvaluator.evaluate(cards)
print(result.hand_rank)  # HandEvaluator.HandRank.ONE_PAIR
print(result.get_rank_name())  # "一对"

var cmp = HandEvaluator.compare_hands(hand1, hand2)
# cmp: 1=hand1大, -1=hand2大, 0=平局
```

### SkillXRay (透视技能)
```gdscript
var xray = SkillXRay.new()
if xray.use(player, opponent):
    var revealed = xray.get_revealed_card()
    print("看到底牌: %s" % revealed.get_display_name())
```

### PokerGame (牌局)
```gdscript
var game = PokerGame.new()
game.start_game(player, opponent)

# 玩家操作
game.player_action(PokerGame.BettingAction.CALL)  # 跟注
game.player_action(PokerGame.BettingAction.RAISE, 100)  # 加注100
```
