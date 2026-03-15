extends Node2D
class_name Character

## Character - 角色基类
## 所有角色（玩家和NPC）的基类

@export var character_name: String = ""
@export var portrait_texture: Texture2D = null

# 角色状态
var current_money: int = 0
var current_aura: int = 100
var max_aura: int = 100

# 手牌数据 (Array of CardData)
var hand_cards: Array = []
var hidden_card = null
var visible_cards: Array = []

# 当前下注
var current_bet: int = 0

# 是否已弃牌
var has_folded: bool = false

# 是否全押
var is_all_in: bool = false

# Visual hand container (from addon)
var visual_hand = null


func _ready():
	pass


func reset_for_round() -> void:
	reset_round()


func reset_round() -> void:
	hand_cards.clear()
	hidden_card = null
	visible_cards.clear()
	current_bet = 0
	has_folded = false
	is_all_in = false


func add_card(card_data, is_hidden: bool = false) -> void:
	hand_cards.append(card_data)
	if is_hidden:
		hidden_card = card_data
	else:
		visible_cards.append(card_data)


func receive_card(card_data, is_hidden: bool = false) -> void:
	add_card(card_data, is_hidden)


func get_hidden_card():
	return hidden_card


func get_visible_cards() -> Array:
	return visible_cards.duplicate()


func get_hand_cards() -> Array:
	return hand_cards.duplicate()


func can_check(call_amount: int) -> bool:
	return current_bet >= call_amount and not has_folded and not is_all_in


func can_call(call_amount: int) -> bool:
	return current_money >= (call_amount - current_bet) and not has_folded and not is_all_in


func can_raise(amount: int) -> bool:
	return current_money >= amount and not has_folded and not is_all_in


func place_bet(amount: int) -> int:
	var actual_bet = min(amount, current_money)
	current_money -= actual_bet
	current_bet += actual_bet
	if current_money == 0:
		is_all_in = true
	return actual_bet


func fold() -> void:
	has_folded = true


func win_pot(amount: int) -> void:
	current_money += amount


func consume_aura(amount: int) -> bool:
	if current_aura >= amount:
		current_aura -= amount
		return true
	return false


func restore_aura(amount: int) -> void:
	current_aura = min(current_aura + amount, max_aura)


func set_aura(amount: int) -> void:
	current_aura = clamp(amount, 0, max_aura)


func get_aura() -> int:
	return current_aura


func get_hand_evaluation() -> HandEvaluator.EvaluationResult:
	return HandEvaluator.evaluate(hand_cards)
