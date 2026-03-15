extends RefCounted
class_name Card

## Card - 扑克牌数据结构
## 表示单张扑克牌

enum Suit {
	CLUBS,      # 梅花 ♣
	DIAMONDS,   # 方块 ♦
	HEARTS,     # 红桃 ♥
	SPADES      # 黑桃 ♠
}

enum Rank {
	TWO = 2,
	THREE = 3,
	FOUR = 4,
	FIVE = 5,
	SIX = 6,
	SEVEN = 7,
	EIGHT = 8,
	NINE = 9,
	TEN = 10,
	JACK = 11,
	QUEEN = 12,
	KING = 13,
	ACE = 14
}

var suit: Suit
var rank: Rank


func _init(s: Suit, r: Rank) -> void:
	suit = s
	rank = r


func get_value() -> int:
	return rank


func get_suit_name() -> String:
	match suit:
		Suit.CLUBS: return "clubs"
		Suit.DIAMONDS: return "diamonds"
		Suit.HEARTS: return "hearts"
		Suit.SPADES: return "spades"
	return ""


func get_rank_name() -> String:
	match rank:
		Rank.TWO: return "2"
		Rank.THREE: return "3"
		Rank.FOUR: return "4"
		Rank.FIVE: return "5"
		Rank.SIX: return "6"
		Rank.SEVEN: return "7"
		Rank.EIGHT: return "8"
		Rank.NINE: return "9"
		Rank.TEN: return "10"
		Rank.JACK: return "jack"
		Rank.QUEEN: return "queen"
		Rank.KING: return "king"
		Rank.ACE: return "ace"
	return ""


func get_texture_name() -> String:
	return "%s_%s" % [get_suit_name(), get_rank_name()]


func to_string() -> String:
	return "%s of %s" % [get_rank_name(), get_suit_name()]


func get_display_name() -> String:
	var suit_names = ["梅花", "方块", "红桃", "黑桃"]
	var rank_names = ["", "", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
	return suit_names[suit] + rank_names[rank]


func compare_to(other: Card) -> int:
	if rank > other.rank:
		return 1
	elif rank < other.rank:
		return -1
	return 0
