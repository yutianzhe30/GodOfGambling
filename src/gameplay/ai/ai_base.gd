extends RefCounted
class_name AIBase

## AIBase - AI基类
## 所有AI类型的基类

var npc: NPC = null


func set_npc(n: NPC) -> void:
	npc = n


func make_decision(game_state: Dictionary) -> Dictionary:
	# 返回决策字典
	# { "action": "fold"|"check"|"call"|"raise", "amount": int }
	
	var call_amount = game_state.get("call_amount", 0)
	var pot = game_state.get("pot", 0)
	var community_cards = game_state.get("community_cards", [])
	
	# 基础AI：根据手牌强度简单决策
	var hand_strength = _evaluate_hand_strength(community_cards)
	
	if hand_strength < 0.3 and call_amount > npc.current_bet * 2:
		return {"action": "fold", "amount": 0}
	
	if hand_strength > 0.7 and npc.current_money > 0:
		var raise_amount = int(npc.current_money * 0.2 * hand_strength)
		return {"action": "raise", "amount": raise_amount}
	
	if call_amount > npc.current_bet:
		return {"action": "call", "amount": 0}
	
	return {"action": "check", "amount": 0}


func _evaluate_hand_strength(community_cards: Array) -> float:
	# 返回0-1的手牌强度值
	if npc.hand.size() == 0:
		return 0.5
	
	var all_cards = npc.hand.get_cards().duplicate()
	all_cards.append_array(community_cards)
	
	if all_cards.size() < 5:
		# 没有足够的牌进行评估，基于单牌大小
		var max_rank = 0
		for card in npc.hand.get_cards():
			max_rank = max(max_rank, card.rank)
		return float(max_rank) / 14.0 * 0.5  # 最高0.5表示不确定
	
	var result = HandEvaluator.evaluate(all_cards)
	
	# 根据牌型返回强度值
	match result.hand_rank:
		HandEvaluator.HandRank.HIGH_CARD: return 0.1 + (result.values[0] / 140.0)
		HandEvaluator.HandRank.ONE_PAIR: return 0.3 + (result.values[0] / 140.0)
		HandEvaluator.HandRank.TWO_PAIRS: return 0.5
		HandEvaluator.HandRank.THREE_OF_A_KIND: return 0.6
		HandEvaluator.HandRank.STRAIGHT: return 0.7
		HandEvaluator.HandRank.FLUSH: return 0.75
		HandEvaluator.HandRank.FULL_HOUSE: return 0.85
		HandEvaluator.HandRank.FOUR_OF_A_KIND: return 0.9
		HandEvaluator.HandRank.STRAIGHT_FLUSH: return 0.95
	
	return 0.5
