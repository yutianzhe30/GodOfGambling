extends AIBase
class_name AIBluffer

## AIBluffer - 偷鸡型AI
## 经常虚张声势

var bluff_frequency: float = 0.4  # 偷鸡频率

func make_decision(game_state: Dictionary) -> Dictionary:
	var call_amount = game_state.get("call_amount", 0)
	var pot = game_state.get("pot", 0)
	var hand_strength = _evaluate_hand_strength(game_state.get("community_cards", []))
	
	# 随机决定是否偷鸡
	var is_bluffing = randf() < bluff_frequency
	
	if is_bluffing and npc.current_money > 0:
		# 偷鸡：大额加注
		var bluff_amount = int(npc.current_money * (0.2 + randf() * 0.3))
		return {"action": "raise", "amount": bluff_amount}
	
	# 非偷鸡情况下，正常但偏松的打法
	if hand_strength < 0.2 and call_amount > npc.current_bet * 2:
		return {"action": "fold", "amount": 0}
	
	if hand_strength > 0.55:
		var raise_amount = int(npc.current_money * 0.25 * hand_strength)
		if raise_amount > 0:
			return {"action": "raise", "amount": raise_amount}
	
	if call_amount > npc.current_bet:
		return {"action": "call", "amount": 0}
	
	return {"action": "check", "amount": 0}
