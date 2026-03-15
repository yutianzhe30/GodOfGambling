extends RefCounted
class_name Hand

## Hand - 手牌管理
## 管理玩家的手牌 (包含底牌和明牌)

var cards: Array[Card] = []
var hidden_card: Card = null
var visible_cards: Array[Card] = []


func add_card_with_hidden(card: Card, is_hidden: bool = false) -> void:
	cards.append(card)
	if is_hidden:
		hidden_card = card
	else:
		visible_cards.append(card)


func add_card(card: Card, is_hidden: bool = false) -> void:
	cards.append(card)
	if is_hidden:
		hidden_card = card
	else:
		visible_cards.append(card)


func get_hidden_card() -> Card:
	return hidden_card


func get_visible_cards() -> Array[Card]:
	return visible_cards.duplicate()


func remove_card(card: Card) -> bool:
	var index = cards.find(card)
	if index >= 0:
		cards.remove_at(index)
		return true
	return false


func replace_card(old_card: Card, new_card: Card) -> bool:
	var index = cards.find(old_card)
	if index >= 0:
		cards[index] = new_card
		return true
	return false


func clear() -> void:
	cards.clear()
	hidden_card = null
	visible_cards.clear()


func size() -> int:
	return cards.size()


func get_card(index: int) -> Card:
	if index >= 0 and index < cards.size():
		return cards[index]
	return null


func get_cards() -> Array[Card]:
	return cards.duplicate()


func sort_by_rank() -> void:
	cards.sort_custom(func(a, b): return a.rank > b.rank)


func sort_by_suit() -> void:
	cards.sort_custom(func(a, b): return a.suit < b.suit if a.suit != b.suit else a.rank > b.rank)
