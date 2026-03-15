extends RefCounted
class_name Deck

## Deck - 牌组管理
## 管理一副扑克牌（洗牌、发牌）

var cards: Array = []  # Array[CardData]
var rng = RandomNumberGenerator.new()


func _init() -> void:
	rng.randomize()
	reset()


func reset() -> void:
	cards.clear()
	# 创建52张牌，名称格式与JSON文件一致
	var suits = [CardData.Suit.CLUBS, CardData.Suit.DIAMONDS, CardData.Suit.HEARTS, CardData.Suit.SPADES]
	for s in suits:
		for r in range(2, 15):
			cards.append(CardData.new(s, r))


func shuffle() -> void:
	for i in range(cards.size() - 1, 0, -1):
		var j = rng.randi() % (i + 1)
		var temp = cards[i]
		cards[i] = cards[j]
		cards[j] = temp


func draw() -> Object:  # Returns CardData or null
	if cards.is_empty():
		return null
	return cards.pop_back()


func draw_n(n: int) -> Array:
	var result = []
	for i in range(n):
		var card = draw()
		if card != null:
			result.append(card)
	return result


func remaining() -> int:
	return cards.size()


func is_empty() -> bool:
	return cards.is_empty()


func size() -> int:
	return cards.size()
