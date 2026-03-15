extends AIBase
class_name AIConservative

## AIConservative - 保守型AI
## 只在有把握时才下注

func make_decision(game_state: Dictionary) -> Dictionary:
	var call_amount = game_state.get("call_amount", 0)
	var pot = game_state.get("pot", 0)
	var hand_strength = _evaluate_hand_strength(game_state.get("community_cards", []))
	
	# 保守型AI需要更高的阈值
	var fold_threshold = 0.4
	var raise_threshold = 0.7
	
	# 如果牌太差直接弃牌
	if hand_strength < fold_threshold and call_amount > npc.current_bet:
		return {"action": "fold", "amount": 0}
	
	# 只有牌很好才加注
	if hand_strength > raise_threshold:
		var raise_amount = int(npc.current_money * 0.15 * hand_strength)
		if raise_amount > 0:
			return {"action": "raise", "amount": raise_amount}
	
	# 否则跟注或看牌
	if call_amount > npc.current_bet:
		return {"action": "call", "amount": 0}
	
	return {"action": "check", "amount": 0}
