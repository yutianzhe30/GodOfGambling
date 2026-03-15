extends Item
class_name ItemChocolate

## ItemChocolate - 巧克力
## 高进最爱，恢复气场

var aura_restore: int = 30


func _init() -> void:
	super._init("巧克力", "恢复30点气场", 10)


func _apply_effect(user: Character) -> void:
	user.restore_aura(aura_restore)
	print("食用巧克力，恢复了 %d 点气场" % aura_restore)
