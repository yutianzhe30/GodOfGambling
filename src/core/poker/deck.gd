extends RefCounted
class_name Deck

## Deck - 牌组
## 管理一副扑克牌（洗牌、发牌）

var cards: Array[Card] = []
var rng = RandomNumberGenerator.new()


func _init() -> void:
	rng.randomize()
	reset()


func reset() -> void:
	cards.clear()
	for s in range(4):
		for r in range(2, 15):
			cards.append(Card.new(s, r))


func shuffle() -> void:
	for i in range(cards.size() - 1, 0, -1):
		var j = rng.randi() % (i + 1)
		var temp = cards[i]
		cards[i] = cards[j]
		cards[j] = temp


func draw() -> Card:
	if cards.is_empty():
		return null
	return cards.pop_back()


func draw_n(n: int) -> Array[Card]:
	var result: Array[Card] = []
	for i in range(n):
		var card = draw()
		if card != null:
			result.append(card)
	return result


func size() -> int:
	return cards.size()


func remaining() -> int:
	return cards.size()


func is_empty() -> bool:
	return cards.is_empty()


func draw_card() -> Card:
	return draw()


func draw_cards(n: int) -> Array[Card]:
	return draw_n(n)
