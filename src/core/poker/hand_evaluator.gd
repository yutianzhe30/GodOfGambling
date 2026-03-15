extends RefCounted
class_name HandEvaluator

## HandEvaluator - 牌型判定器
## 判定五张牌梭哈的牌型

enum HandRank {
	HIGH_CARD = 0,       # 高牌
	ONE_PAIR = 1,        # 一对
	TWO_PAIRS = 2,       # 两对
	THREE_OF_A_KIND = 3, # 三条
	STRAIGHT = 4,        # 顺子
	FLUSH = 5,           # 同花
	FULL_HOUSE = 6,      # 葫芦
	FOUR_OF_A_KIND = 7,  # 四条
	STRAIGHT_FLUSH = 8   # 同花顺
}

class EvaluationResult:
	var hand_rank: HandRank
	var values: Array = []  # 用于比较相同牌型的大小

	func _init(rank: HandRank, vals: Array = []):
		hand_rank = rank
		values = vals
	
	func get_rank_name() -> String:
		return HandEvaluator.get_hand_rank_name(hand_rank)
	
	func compare_to(other: EvaluationResult) -> int:
		if hand_rank > other.hand_rank:
			return 1
		elif hand_rank < other.hand_rank:
			return -1
		
		for i in range(min(values.size(), other.values.size())):
			if values[i] > other.values[i]:
				return 1
			elif values[i] < other.values[i]:
				return -1
		
		return 0


static func evaluate(cards: Array) -> EvaluationResult:
	if cards.size() != 5:
		return EvaluationResult.new(HandRank.HIGH_CARD, [0])
	
	# 统计牌面点数和花色
	var rank_counts = {}
	var suit_counts = {}
	
	for card in cards:
		rank_counts[card.rank] = rank_counts.get(card.rank, 0) + 1
		suit_counts[card.suit] = suit_counts.get(card.suit, 0) + 1
	
	var is_flush = suit_counts.values().any(func(count): return count == 5)
	var is_straight = _check_straight(rank_counts.keys())
	
	# 同花顺
	if is_straight and is_flush:
		var straight_high = _get_straight_high(rank_counts.keys())
		return EvaluationResult.new(HandRank.STRAIGHT_FLUSH, [straight_high])
	
	# 四条
	if rank_counts.values().has(4):
		var quad_rank = _get_key_by_value(rank_counts, 4)
		var kicker = _get_key_by_value(rank_counts, 1)
		return EvaluationResult.new(HandRank.FOUR_OF_A_KIND, [quad_rank, kicker])
	
	# 葫芦
	if rank_counts.values().has(3) and rank_counts.values().has(2):
		var trip_rank = _get_key_by_value(rank_counts, 3)
		var pair_rank = _get_key_by_value(rank_counts, 2)
		return EvaluationResult.new(HandRank.FULL_HOUSE, [trip_rank, pair_rank])
	
	# 同花
	if is_flush:
		var sorted_ranks = rank_counts.keys()
		sorted_ranks.sort()
		sorted_ranks.reverse()
		return EvaluationResult.new(HandRank.FLUSH, sorted_ranks)
	
	# 顺子
	if is_straight:
		var straight_high = _get_straight_high(rank_counts.keys())
		return EvaluationResult.new(HandRank.STRAIGHT, [straight_high])
	
	# 三条
	if rank_counts.values().has(3):
		var trip_rank = _get_key_by_value(rank_counts, 3)
		var kickers = rank_counts.keys().filter(func(r): return r != trip_rank)
		kickers.sort()
		kickers.reverse()
		return EvaluationResult.new(HandRank.THREE_OF_A_KIND, [trip_rank] + kickers)
	
	# 两对
	var pairs = rank_counts.values().filter(func(c): return c == 2)
	if pairs.size() == 2:
		var pair_ranks = rank_counts.keys().filter(func(r): return rank_counts[r] == 2)
		pair_ranks.sort()
		pair_ranks.reverse()
		var kicker = _get_key_by_value(rank_counts, 1)
		return EvaluationResult.new(HandRank.TWO_PAIRS, pair_ranks + [kicker])
	
	# 一对
	if rank_counts.values().has(2):
		var pair_rank = _get_key_by_value(rank_counts, 2)
		var kickers = rank_counts.keys().filter(func(r): return r != pair_rank)
		kickers.sort()
		kickers.reverse()
		return EvaluationResult.new(HandRank.ONE_PAIR, [pair_rank] + kickers)
	
	# 高牌
	var sorted = rank_counts.keys()
	sorted.sort()
	sorted.reverse()
	return EvaluationResult.new(HandRank.HIGH_CARD, sorted)


static func _check_straight(ranks: Array) -> bool:
	if ranks.size() != 5:
		return false
	
	var sorted = ranks.duplicate()
	sorted.sort()
	
	# A-2-3-4-5 特殊处理 (A作为1)
	if sorted == [2, 3, 4, 5, 14]:
		return true
	
	for i in range(1, sorted.size()):
		if sorted[i] != sorted[i-1] + 1:
			return false
	return true


static func _get_straight_high(ranks: Array) -> int:
	var sorted = ranks.duplicate()
	sorted.sort()
	# A-2-3-4-5 顺子，高点是5不是A
	if sorted == [2, 3, 4, 5, 14]:
		return 5
	return sorted[-1]


static func _get_key_by_value(dict: Dictionary, value) -> int:
	for key in dict.keys():
		if dict[key] == value:
			return key
	return 0


static func compare_hands(hand1: Array, hand2: Array) -> int:
	var result1 = evaluate(hand1)
	var result2 = evaluate(hand2)
	return result1.compare_to(result2)


static func get_hand_rank_name(rank: HandRank) -> String:
	match rank:
		HandRank.HIGH_CARD: return "高牌"
		HandRank.ONE_PAIR: return "一对"
		HandRank.TWO_PAIRS: return "两对"
		HandRank.THREE_OF_A_KIND: return "三条"
		HandRank.STRAIGHT: return "顺子"
		HandRank.FLUSH: return "同花"
		HandRank.FULL_HOUSE: return "葫芦"
		HandRank.FOUR_OF_A_KIND: return "四条"
		HandRank.STRAIGHT_FLUSH: return "同花顺"
	return "未知"
