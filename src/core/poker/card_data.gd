extends RefCounted
class_name CardData

## CardData - 扑克牌数据结构
## 纯数据结构，用于扑克逻辑计算

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
var card_name: String  # 对应JSON文件名如 "club_10"


func _init(s: Suit = Suit.CLUBS, r: Rank = Rank.TWO, name: String = "") -> void:
	suit = s
	rank = r
	card_name = name if name != "" else _generate_name()


func _generate_name() -> String:
	var suit_names = ["club", "diamond", "heart", "spade"]
	var rank_names = ["", "", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
	return "%s_%s" % [suit_names[suit], rank_names[rank]]


func get_value() -> int:
	return rank


func get_display_name() -> String:
	var suit_names = ["梅花", "方块", "红桃", "黑桃"]
	var rank_names = ["", "", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
	return suit_names[suit] + rank_names[rank]


func get_suit_name() -> String:
	match suit:
		Suit.CLUBS: return "club"
		Suit.DIAMONDS: return "diamond"
		Suit.HEARTS: return "heart"
		Suit.SPADES: return "spade"
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
		Rank.JACK: return "J"
		Rank.QUEEN: return "Q"
		Rank.KING: return "K"
		Rank.ACE: return "A"
	return ""


func compare_to(other) -> int:
	if rank > other.rank:
		return 1
	elif rank < other.rank:
		return -1
	return 0


## 从JSON文件名创建CardData (如 "club_10" -> CardData)
static func from_name(name: String) -> Object:
	var parts = name.split("_")
	if parts.size() != 2:
		return null
	
	var suit: Suit
	match parts[0]:
		"club": suit = Suit.CLUBS
		"diamond": suit = Suit.DIAMONDS
		"heart": suit = Suit.HEARTS
		"spade": suit = Suit.SPADES
		_: return null
	
	var rank: Rank
	match parts[1]:
		"2": rank = Rank.TWO
		"3": rank = Rank.THREE
		"4": rank = Rank.FOUR
		"5": rank = Rank.FIVE
		"6": rank = Rank.SIX
		"7": rank = Rank.SEVEN
		"8": rank = Rank.EIGHT
		"9": rank = Rank.NINE
		"10": rank = Rank.TEN
		"J": rank = Rank.JACK
		"Q": rank = Rank.QUEEN
		"K": rank = Rank.KING
		"A": rank = Rank.ACE
		_: return null
	
	return CardData.new(suit, rank, name)
