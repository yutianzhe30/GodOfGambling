extends AIBase
class_name AIAggressive

## AIAggressive - 激进型AI
## 倾向于加注和全押

func make_decision(game_state: Dictionary) -> Dictionary:
	var call_amount = game_state.get("call_amount", 0)
	var hand_strength = _evaluate_hand_strength(game_state.get("community_cards", []))
	
	# 激进型AI会虚张声势
	var effective_strength = hand_strength + randf() * 0.2
	effective_strength = min(effective_strength, 1.0)
	
	# 即使牌不好也有概率偷鸡
	if effective_strength < 0.3:
		if randf() < 0.3:  # 30%概率偷鸡
			var bluff_amount = int(npc.current_money * 0.3)
			return {"action": "raise", "amount": bluff_amount}
		elif call_amount > npc.current_bet:
			return {"action": "fold", "amount": 0}
	
	if effective_strength > 0.5:
		var raise_amount = int(npc.current_money * 0.3 * effective_strength)
		if raise_amount > 0:
			return {"action": "raise", "amount": raise_amount}
	
	if call_amount > npc.current_bet:
		return {"action": "call", "amount": 0}
	
	return {"action": "check", "amount": 0}
